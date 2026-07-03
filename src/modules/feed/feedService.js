import { prisma } from '../../config/db.js';

export async function getPublishedCvFeed({ page = 1, limit = 10, location }) {
  const skip = (page - 1) * limit;

  const where = {
    isPublished: true,
    ...(location && {
      user: { profile: { location: { contains: location } } },
    }),
  };

  const [items, total] = await Promise.all([
    prisma.cV.findMany({
      where,
      skip,
      take: Number(limit),
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            id: true,
            profile: {
              select: { fullName: true, location: true, photoUrl: true },
            },
          },
        },
      },
    }),
    prisma.cV.count({ where }),
  ]);

  return {
    items,
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}

export async function getCvDetailById(cvId) {
  const cv = await prisma.cV.findFirst({
    where: { id: cvId, isPublished: true },
    include: {
      user: {
        select: {
          id: true,
          profile: { select: { fullName: true, location: true, photoUrl: true, phone: true } },
        },
      },
    },
  });

  if (!cv) {
    throw { status: 404, message: 'CV tidak ditemukan atau belum dipublish' };
  }

  return cv;
}