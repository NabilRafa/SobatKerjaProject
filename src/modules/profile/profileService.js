import { prisma } from '../../config/db.js';

export async function getProfileByUserId(userId) {
  const profile = await prisma.profile.findUnique({
    where: { userId },
    include: { user: { select: { id: true, email: true, role: true, createdAt: true } } },
  });

  if (!profile) {
    throw { status: 404, message: 'Profil tidak ditemukan' };
  }

  return profile;
}

export async function updateProfile(userId, data) {
  const { fullName, phone, location } = data;

  const updated = await prisma.profile.update({
    where: { userId },
    data: {
      ...(fullName && { fullName }),
      ...(phone && { phone }),
      ...(location && { location }),
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