import { prisma } from '../../config/db.js';

export async function createRating(fromUserId, applicationId, { score, comment }) {
  if (!score || score < 1 || score > 5) {
    throw { status: 400, message: 'Score harus antara 1-5' };
  }

  const application = await prisma.application.findUnique({
    where: { id: applicationId },
    include: { job: true },
  });

  if (!application) throw { status: 404, message: 'Lamaran tidak ditemukan' };
  if (application.status !== 'COMPLETED') {
    throw { status: 400, message: 'Rating hanya bisa diberikan setelah pekerjaan selesai (status COMPLETED)' };
  }

  const isEmployer = application.job.employerId === fromUserId;
  const isApplicant = application.applicantId === fromUserId;

  if (!isEmployer && !isApplicant) {
    throw { status: 403, message: 'Anda tidak terlibat dalam lamaran ini' };
  }

  const toUserId = isEmployer ? application.applicantId : application.job.employerId;

  const existing = await prisma.rating.findUnique({
    where: { applicationId_fromUserId: { applicationId, fromUserId } },
  });
  if (existing) throw { status: 409, message: 'Anda sudah memberikan rating untuk lamaran ini' };

  return prisma.rating.create({
    data: { applicationId, fromUserId, toUserId, score, comment },
  });
}

export async function getUserRatings(userId) {
  const ratings = await prisma.rating.findMany({
    where: { toUserId: userId },
    orderBy: { createdAt: 'desc' },
    include: {
      fromUser: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } },
    },
  });

  const average = ratings.length
    ? ratings.reduce((sum, r) => sum + r.score, 0) / ratings.length
    : 0;

  return {
    average: Math.round(average * 10) / 10,
    total: ratings.length,
    ratings,
  };
}