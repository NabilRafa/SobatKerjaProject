import { prisma } from '../../config/db.js';

export async function applyToJob(applicantId, jobId, { cvIds, contactName, contactPhone, appliedSkill, portfolioUrls }) {
  if (!Array.isArray(cvIds) || cvIds.length === 0) {
    throw { status: 400, message: 'Minimal pilih 1 CV untuk melamar' };
  }
  if (!contactName || !contactPhone) {
    throw { status: 400, message: 'Nama dan nomor telepon wajib diisi' };
  }

  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });
  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.status !== 'OPEN') throw { status: 400, message: 'Lowongan sudah ditutup' };

  const ownedCvs = await prisma.cV.findMany({ where: { id: { in: cvIds }, userId: applicantId } });
  if (ownedCvs.length !== cvIds.length) {
    throw { status: 403, message: 'Salah satu CV yang dipilih tidak valid atau bukan milik Anda' };
  }

  const existing = await prisma.application.findUnique({
    where: { jobId_applicantId: { jobId, applicantId } },
  });
  if (existing) throw { status: 409, message: 'Anda sudah melamar atau menerima tawaran untuk lowongan ini' };

  return prisma.application.create({
    data: {
      jobId, applicantId, type: 'APPLICATION',
      cvIds, contactName, contactPhone,
      appliedSkill: appliedSkill || null,
      portfolioUrls: portfolioUrls || [],
    },
  });
}

export async function createOffer(employerId, jobId, workerId) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });
  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.employerId !== employerId) throw { status: 403, message: 'Anda tidak berhak menawarkan pekerjaan ini' };
  if (job.status !== 'OPEN') throw { status: 400, message: 'Lowongan sudah ditutup' };

  const worker = await prisma.user.findUnique({ where: { id: workerId }, include: { profile: true } });
  if (!worker || worker.role !== 'WORKER') throw { status: 404, message: 'Worker tidak ditemukan' };

  const existing = await prisma.application.findUnique({
    where: { jobId_applicantId: { jobId, applicantId: workerId } },
  });
  if (existing) throw { status: 409, message: 'Worker ini sudah melamar atau sudah pernah ditawarkan pekerjaan ini' };

  return prisma.application.create({
    data: {
      jobId,
      applicantId: workerId,
      type: 'OFFER',
      contactName: worker.profile?.fullName || '',
      contactPhone: worker.profile?.phone || '',
    },
  });
}

function jobCardSelect() {
  return {
    id: true, title: true, description: true, locationArea: true, fullAddress: true,
    salaryAmount: true, salaryType: true, totalSlot: true, filledSlot: true, status: true,
    employer: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } },
  };
}

export async function getMyApplications(applicantId, type, keyword) {
  const applications = await prisma.application.findMany({
    where: {
      applicantId,
      ...(type && { type }),
      ...(keyword && { job: { title: { contains: keyword } } }),
    },
    orderBy: { appliedAt: 'desc' },
    include: { job: { select: jobCardSelect() } },
  });

  return applications.map(app => ({
    ...app,
    job: { ...app.job, availableSlot: Math.max(app.job.totalSlot - app.job.filledSlot, 0) },
  }));
}

export async function getApplicantsForJob(employerId, jobId) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });
  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.employerId !== employerId) throw { status: 403, message: 'Anda tidak berhak melihat pelamar lowongan ini' };

  const applications = await prisma.application.findMany({
    where: { jobId },
    orderBy: { appliedAt: 'desc' },
    include: {
      applicant: {
        select: {
          id: true,
          profile: { select: { fullName: true, photoUrl: true, location: true, phone: true, bio: true, skills: true } },
        },
      },
    },
  });

  const applicantIds = applications.map(app => app.applicantId);
  const ratingAggs = await prisma.rating.groupBy({
    by: ['toUserId'],
    where: { toUserId: { in: applicantIds } },
    _avg: { score: true },
    _count: { score: true },
  });
  const ratingMap = new Map(ratingAggs.map(r => [r.toUserId, r]));

  return applications.map(app => {
    const ratingData = ratingMap.get(app.applicantId);
    return {
      ...app,
      applicant: {
        ...app.applicant,
        rating: {
          average: ratingData?._avg.score ? Math.round(ratingData._avg.score * 10) / 10 : 0,
          total: ratingData?._count.score || 0,
        },
      },
    };
  });
}

export async function getApplicationDetail(userId, applicationId) {
  const application = await prisma.application.findUnique({
    where: { id: applicationId },
    include: {
      job: true,
      applicant: {
        select: {
          id: true,
          profile: { select: { fullName: true, photoUrl: true, location: true, phone: true, bio: true, skills: true } },
        },
      },
    },
  });
  if (!application) throw { status: 404, message: 'Lamaran tidak ditemukan' };

  const isEmployer = application.job.employerId === userId;
  const isApplicant = application.applicantId === userId;
  if (!isEmployer && !isApplicant) throw { status: 403, message: 'Anda tidak berhak melihat lamaran ini' };

  const cvIds = Array.isArray(application.cvIds) ? application.cvIds : [];
  const cvs = cvIds.length
    ? await prisma.cV.findMany({ where: { id: { in: cvIds } }, select: { id: true, label: true, pdfUrl: true, templateId: true } })
    : [];

  const ratings = await prisma.rating.findMany({
    where: { toUserId: application.applicantId },
    orderBy: { createdAt: 'desc' },
    include: { fromUser: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } } },
  });
  const average = ratings.length ? Math.round((ratings.reduce((s, r) => s + r.score, 0) / ratings.length) * 10) / 10 : 0;

  return {
    id: application.id,
    type: application.type,
    status: application.status,
    contactName: application.contactName,
    contactPhone: application.contactPhone,
    appliedSkill: application.appliedSkill,
    job: application.job,
    applicant: { ...application.applicant.profile, userId: application.applicant.id },
    cvs,
    portfolioUrls: application.portfolioUrls || [],
    rating: { average, total: ratings.length, reviews: ratings },
  };
}

export async function respondToApplication(userId, applicationId, status) {
  const application = await prisma.application.findUnique({
    where: { id: applicationId },
    include: { job: true },
  });
  if (!application) throw { status: 404, message: 'Lamaran tidak ditemukan' };

  const isEmployer = application.job.employerId === userId;
  const isApplicant = application.applicantId === userId;

  if (status === 'ACCEPTED' || status === 'REJECTED') {
    if (application.type === 'APPLICATION' && !isEmployer) {
      throw { status: 403, message: 'Hanya pemberi kerja yang bisa merespon lamaran ini' };
    }
    if (application.type === 'OFFER' && !isApplicant) {
      throw { status: 403, message: 'Hanya penerima tawaran yang bisa merespon tawaran ini' };
    }
  } else if (status === 'COMPLETED') {
    if (!isEmployer) throw { status: 403, message: 'Hanya pemberi kerja yang bisa menandai pekerjaan selesai' };
  } else {
    throw { status: 400, message: 'Status tidak valid' };
  }

  const wasAccepted = application.status === 'ACCEPTED';
  const willBeAccepted = status === 'ACCEPTED';

  return prisma.$transaction(async (tx) => {
    const updated = await tx.application.update({ where: { id: applicationId }, data: { status } });

    if (!wasAccepted && willBeAccepted) {
      const job = await tx.jobPosting.update({ where: { id: application.jobId }, data: { filledSlot: { increment: 1 } } });
      if (job.filledSlot >= job.totalSlot) {
        await tx.jobPosting.update({ where: { id: application.jobId }, data: { status: 'CLOSED' } });
      }
    }
    if (wasAccepted && !willBeAccepted) {
      const job = await tx.jobPosting.findUnique({ where: { id: application.jobId } });
      await tx.jobPosting.update({
        where: { id: application.jobId },
        data: { filledSlot: { decrement: 1 }, ...(job.status === 'CLOSED' && { status: 'OPEN' }) },
      });
    }
    return updated;
  });
}

export async function cancelApplication(workerId, applicationId) {
  const application = await prisma.application.findUnique({ where: { id: applicationId } });
  if (!application) throw { status: 404, message: 'Lamaran tidak ditemukan' };
  if (application.applicantId !== workerId) throw { status: 403, message: 'Anda tidak berhak membatalkan lamaran ini' };
  if (application.type !== 'APPLICATION') throw { status: 400, message: 'Tawaran tidak bisa dibatalkan dengan cara ini, silakan tolak tawaran' };
  if (!['PENDING', 'ACCEPTED'].includes(application.status)) {
    throw { status: 400, message: 'Lamaran ini tidak bisa dibatalkan' };
  }

  const wasAccepted = application.status === 'ACCEPTED';

  return prisma.$transaction(async (tx) => {
    const updated = await tx.application.update({ where: { id: applicationId }, data: { status: 'CANCELLED' } });
    if (wasAccepted) {
      const job = await tx.jobPosting.findUnique({ where: { id: application.jobId } });
      await tx.jobPosting.update({
        where: { id: application.jobId },
        data: { filledSlot: { decrement: 1 }, ...(job.status === 'CLOSED' && { status: 'OPEN' }) },
      });
    }
    return updated;
  });
}