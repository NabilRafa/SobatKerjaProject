import cloudinary from '../../config/cloudinary.js';
import { prisma } from '../../config/db.js';
import { generatePdfFromHtml } from '../../utils/pdfGenerator.js';
import { renderCvTemplate, getAvailableTemplates } from './cvTemplates.js';

export async function createCv(userId, label, dataJson, templateId = 'template1') {
  const validTemplateIds = getAvailableTemplates().map(t => t.id);
  if (!validTemplateIds.includes(templateId)) {
    throw { status: 400, message: 'Template tidak valid' };
  }
  if (!label || label.trim() === '') {
    throw { status: 400, message: 'Label CV wajib diisi, contoh: "CV Tukang Bangunan"' };
  }

  const contactInfo = await getContactInfo(userId);
  const finalDataJson = {
    ...dataJson,
    email: dataJson.email || contactInfo.email,
    phone: dataJson.phone || contactInfo.phone,
    address: dataJson.address || contactInfo.address,
  };

  const html = renderCvTemplate(templateId, finalDataJson);
  const pdfBuffer = await generatePdfFromHtml(html);
  const pdfUrl = await uploadPdfToCloudinary(pdfBuffer, userId);

  return prisma.cV.create({
    data: { userId, label, templateId, dataJson: finalDataJson, pdfUrl },
  });
}

async function getContactInfo(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: { profile: true },
  });

  return {
    email: user?.email || '',
    phone: user?.profile?.phone || '',
    address: user?.profile?.location || '',
  };
}

export async function updateCv(userId, cvId, { label, dataJson, templateId }) {
  const existing = await prisma.cV.findUnique({ where: { id: cvId } });
  if (!existing) throw { status: 404, message: 'CV tidak ditemukan' };
  if (existing.userId !== userId) throw { status: 403, message: 'Anda tidak berhak mengubah CV ini' };

  const finalTemplateId = templateId || existing.templateId;

  let finalDataJson = existing.dataJson;
  if (dataJson) {
    const contactInfo = await getContactInfo(userId);
    finalDataJson = {
      ...dataJson,
      email: dataJson.email || contactInfo.email,
      phone: dataJson.phone || contactInfo.phone,
      address: dataJson.address || contactInfo.address,
    };
  }

  const html = renderCvTemplate(finalTemplateId, finalDataJson);
  const pdfBuffer = await generatePdfFromHtml(html);
  const pdfUrl = await uploadPdfToCloudinary(pdfBuffer, cvId);

  return prisma.cV.update({
    where: { id: cvId },
    data: {
      ...(label && { label }),
      templateId: finalTemplateId,
      dataJson: finalDataJson,
      pdfUrl,
    },
  });
}

export async function deleteCv(userId, cvId) {
  const existing = await prisma.cV.findUnique({ where: { id: cvId } });
  if (!existing) throw { status: 404, message: 'CV tidak ditemukan' };
  if (existing.userId !== userId) throw { status: 403, message: 'Anda tidak berhak menghapus CV ini' };

  await prisma.cV.delete({ where: { id: cvId } });
  return { message: 'CV berhasil dihapus' };
}

function uploadPdfToCloudinary(buffer, uniqueKey) {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        resource_type: 'raw',
        folder: 'sobat_kerja/cv_pdfs',
        public_id: `cv_${uniqueKey}_${Date.now()}`,
        overwrite: true,
        format: 'pdf',
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result.secure_url);
      }
    );
    stream.end(buffer);
  });
}

export async function getMyCvs(userId) {
  return prisma.cV.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });
}

export async function getCvById(userId, cvId) {
  const cv = await prisma.cV.findUnique({ where: { id: cvId } });
  if (!cv) throw { status: 404, message: 'CV tidak ditemukan' };
  if (cv.userId !== userId) throw { status: 403, message: 'Anda tidak berhak melihat CV ini' };
  return cv;
}

export async function togglePublish(userId, cvId, isPublished) {
  const existing = await prisma.cV.findUnique({ where: { id: cvId } });
  if (!existing) throw { status: 404, message: 'CV tidak ditemukan' };
  if (existing.userId !== userId) throw { status: 403, message: 'Anda tidak berhak mengubah CV ini' };

  return prisma.cV.update({ where: { id: cvId }, data: { isPublished } });
}