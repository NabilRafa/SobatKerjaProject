import { prisma } from '../../config/db.js';

export async function applyToJob(applicantId, jobId) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });
  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.status !== 'OPEN') throw { status: 400, message: 'Lowongan sudah ditutup' };

  const cv = await prisma.cV.findUnique({ where: { userId: applicantId } });
  if (!cv) throw { status: 400, message: 'Anda harus membuat CV terlebih dahulu sebelum melamar' };

  const existing = await prisma.application.findUnique({
    where: { jobId_applicantId: { jobId, applicantId } },
  });
  if (existing) throw { status: 409, message: 'Anda sudah melamar lowongan ini' };

  return prisma.application.create({
    data: { jobId, applicantId },
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
          cv: { select: { pdfUrl: true } },
        },
      },
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

  return prisma.application.update({
    where: { id: applicationId },
    data: { status },
  });
}