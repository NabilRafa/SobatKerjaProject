import { prisma } from '../../config/db.js';

export async function getProfileByUserId(userId) {
  const profile = await prisma.profile.findUnique({
    where: { userId },
    include: { user: { select: { id: true, email: true, role: true, createdAt: true } } },
  });

  if (!profile) throw { status: 404, message: 'Profil tidak ditemukan' };

  const cvs = await prisma.cV.findMany({
    where: { userId },
    select: { id: true, label: true, pdfUrl: true, isPublished: true, templateId: true, createdAt: true },
    orderBy: { createdAt: 'desc' },
  });

  const portfolios = await prisma.portfolio.findMany({ where: { userId }, orderBy: { createdAt: 'desc' } });

  const ratingAgg = await prisma.rating.aggregate({
    where: { toUserId: userId },
    _avg: { score: true },
    _count: { score: true },
  });

  return {
    ...profile,
    cvs,
    portfolios,
    rating: {
      average: ratingAgg._avg.score ? Math.round(ratingAgg._avg.score * 10) / 10 : 0,
      total: ratingAgg._count.score,
    },
  };
}

export async function updateProfile(userId, data) {
  const { fullName, phone, location, bio, skills } = data;

  const updated = await prisma.profile.update({
    where: { userId },
    data: {
      ...(fullName && { fullName }),
      ...(phone && { phone }),
      ...(location && { location }),
      ...(bio !== undefined && { bio }),
      ...(skills && { skills }),
    },
  });

  return updated;
}

export async function updateProfilePhoto(userId, photoUrl) {
  const updated = await prisma.profile.update({
    where: { userId },
    data: { photoUrl },
  });

  return updated;
}