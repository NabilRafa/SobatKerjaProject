import { prisma } from '../../config/db.js';

export async function applyToJob(applicantId, jobId, { cvId, contactName, contactPhone, appliedSkill, portfolioUrls }) {
  if (!cvId || !contactName || !contactPhone) {
    throw { status: 400, message: 'CV, nama, dan nomor telepon wajib diisi' };
  }

  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });
  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.status !== 'OPEN') throw { status: 400, message: 'Lowongan sudah ditutup' };

  const cv = await prisma.cV.findUnique({ where: { id: cvId } });
  if (!cv) throw { status: 404, message: 'CV tidak ditemukan' };
  if (cv.userId !== applicantId) throw { status: 403, message: 'CV ini bukan milik Anda' };

  const existing = await prisma.application.findUnique({
    where: { jobId_applicantId: { jobId, applicantId } },
  });
  if (existing) throw { status: 409, message: 'Anda sudah melamar lowongan ini' };

  return prisma.application.create({
    data: {
      jobId,
      applicantId,
      cvId,
      contactName,
      contactPhone,
      appliedSkill: appliedSkill || null,
      portfolioUrls: portfolioUrls || [],
    },
  });
}

export async function getMyApplications(applicantId) {
  return prisma.application.findMany({
    where: { applicantId },
    orderBy: { appliedAt: 'desc' },
    include: {
      job: {
        select: {
          id: true, title: true, category: true, location: true, status: true,
          employer: { select: { profile: { select: { fullName: true } } } },
        },
      },
    },
  });
}

export async function getApplicantsForJob(employerId, jobId) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });
  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.employerId !== employerId) throw { status: 403, message: 'Anda tidak berhak melihat pelamar lowongan ini' };

  return prisma.application.findMany({
    where: { jobId },
    orderBy: { appliedAt: 'desc' },
    include: {
      applicant: {
        select: {
          id: true,
          profile: { select: { fullName: true, photoUrl: true, location: true, phone: true } },
        },
      },
      cv: { select: { id: true, label: true, pdfUrl: true } },
    },
  });
}

export async function updateApplicationStatus(employerId, applicationId, status) {
  const validStatuses = ['ACCEPTED', 'REJECTED', 'COMPLETED'];
  if (!validStatuses.includes(status)) {
    throw { status: 400, message: 'Status tidak valid' };
  }

  const application = await prisma.application.findUnique({
    where: { id: applicationId },
    include: { job: true },
  });

  if (!application) throw { status: 404, message: 'Lamaran tidak ditemukan' };
  if (application.job.employerId !== employerId) {
    throw { status: 403, message: 'Anda tidak berhak mengubah status lamaran ini' };
  }

  const wasAccepted = application.status === 'ACCEPTED';
  const willBeAccepted = status === 'ACCEPTED';

  return prisma.$transaction(async (tx) => {
    const updatedApplication = await tx.application.update({
      where: { id: applicationId },
      data: { status },
    });

    if (!wasAccepted && willBeAccepted) {
      const job = await tx.jobPosting.update({
        where: { id: application.jobId },
        data: { filledSlot: { increment: 1 } },
      });

      if (job.filledSlot >= job.totalSlot) {
        await tx.jobPosting.update({ where: { id: application.jobId }, data: { status: 'CLOSED' } });
      }
    }

    if (wasAccepted && !willBeAccepted) {
      const job = await tx.jobPosting.findUnique({ where: { id: application.jobId } });
      await tx.jobPosting.update({
        where: { id: application.jobId },
        data: {
          filledSlot: { decrement: 1 },
          ...(job.status === 'CLOSED' && { status: 'OPEN' }),
        },
      });
    }

    return updatedApplication;
  });
}