import cloudinary from '../../config/cloudinary.js';
import { prisma } from '../../config/db.js';
import { generatePdfFromHtml } from '../../utils/pdfGenerator.js';
import { renderCvTemplate } from './cvTemplates.js';

export async function upsertCv(userId, dataJson) {
  const templateId = 'template1';
  const html = renderCvTemplate(templateId, dataJson);
  const pdfBuffer = await generatePdfFromHtml(html);
  const pdfUrl = await uploadPdfToCloudinary(pdfBuffer, userId);

  const cv = await prisma.cV.upsert({
    where: { userId },
    update: { templateId, dataJson, pdfUrl },
    create: { userId, templateId, dataJson, pdfUrl },
  });

  return cv;
}

function uploadPdfToCloudinary(buffer, userId) {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        resource_type: 'raw',
        folder: 'sobat_kerja/cv_pdfs',
        public_id: `cv_${userId}`,
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

export async function getMyCv(userId) {
  const cv = await prisma.cV.findUnique({ where: { userId } });
  if (!cv) {
    throw { status: 404, message: 'CV belum dibuat, silakan generate dulu' };
  }
  return cv;
}

export async function togglePublish(userId, isPublished) {
  const existing = await prisma.cV.findUnique({ where: { userId } });
  if (!existing) {
    throw { status: 404, message: 'CV belum dibuat, tidak bisa dipublish' };
  }

  return prisma.cV.update({
    where: { userId },
    data: { isPublished },
  });
}