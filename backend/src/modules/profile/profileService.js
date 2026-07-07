import { prisma } from '../../config/db.js';

export async function getProfileByUserId(userId) {
  const profile = await prisma.profile.findUnique({
    where: { userId },
    include: { user: { select: { id: true, email: true, role: true, createdAt: true } } },
  });

  if (!profile) throw { status: 404, message: 'Profil tidak ditemukan' };

  const ratings = await prisma.rating.findMany({
    where: { toUserId: userId },
    orderBy: { createdAt: 'desc' },
    include: {
      fromUser: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } },
    },
  });

  const average = ratings.length
    ? Math.round((ratings.reduce((sum, r) => sum + r.score, 0) / ratings.length) * 10) / 10
    : 0;

  const rating = { average, total: ratings.length, reviews: ratings };

  if (profile.user.role === 'EMPLOYER') {
    return {
      id: profile.id,
      fullName: profile.fullName,
      phone: profile.phone,
      location: profile.location,
      photoUrl: profile.photoUrl,
      user: profile.user,
      rating,
    };
  }

  // WORKER: lengkap dengan bio, skills, cv, portfolio
  const cvs = await prisma.cV.findMany({
    where: { userId },
    select: { id: true, label: true, pdfUrl: true, isPublished: true, templateId: true, createdAt: true },
    orderBy: { createdAt: 'desc' },
  });

  const portfolios = await prisma.portfolio.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });

  return {
    ...profile,
    cvs,
    portfolios,
    rating,
  };
}

export async function getPublicProfileByUserId(targetUserId) {
  const profile = await prisma.profile.findUnique({
    where: { userId: targetUserId },
    include: { user: { select: { id: true, role: true } } },
  });

  if (!profile) throw { status: 404, message: 'Profil tidak ditemukan' };

  const ratings = await prisma.rating.findMany({
    where: { toUserId: targetUserId },
    orderBy: { createdAt: 'desc' },
    include: {
      fromUser: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } },
    },
  });

  const average = ratings.length
    ? Math.round((ratings.reduce((sum, r) => sum + r.score, 0) / ratings.length) * 10) / 10
    : 0;

  const rating = { average, total: ratings.length, reviews: ratings };

  if (profile.user.role === 'EMPLOYER') {
    return {
      fullName: profile.fullName,
      phone: profile.phone,
      location: profile.location,
      photoUrl: profile.photoUrl,
      rating,
    };
  }

  const cvs = await prisma.cV.findMany({
    where: { userId: targetUserId },
    select: { id: true, label: true, pdfUrl: true, templateId: true },
    orderBy: { createdAt: 'desc' },
  });

  const portfolios = await prisma.portfolio.findMany({
    where: { userId: targetUserId },
    orderBy: { createdAt: 'desc' },
  });

  return {
    fullName: profile.fullName,
    phone: profile.phone,
    location: profile.location,
    photoUrl: profile.photoUrl,
    bio: profile.bio,
    skills: profile.skills,
    cvs,
    portfolios,
    rating,
  };
}

export async function updateProfile(userId, data) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw { status: 404, message: 'User tidak ditemukan' };

  const { fullName, phone, location, bio, skills } = data;

  const updateData = {
    ...(fullName && { fullName }),
    ...(phone && { phone }),
    ...(location && { location }),
  };

  // bio & skills hanya berlaku untuk WORKER
  if (user.role === 'WORKER') {
    if (bio !== undefined) updateData.bio = bio;
    if (skills) updateData.skills = skills;
  }

  const updated = await prisma.profile.update({
    where: { userId },
    data: updateData,
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