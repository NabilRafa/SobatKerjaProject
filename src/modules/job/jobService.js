import { prisma } from '../../config/db.js';

export async function createJob(employerId, data) {
  const { title, description, category, location } = data;

  if (!title || !description || !category || !location) {
    throw { status: 400, message: 'Semua field wajib diisi' };
  }

  return prisma.jobPosting.create({
    data: { employerId, title, description, category, location },
  });
}

export async function updateJob(employerId, jobId, data) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });

  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.employerId !== employerId) throw { status: 403, message: 'Anda tidak berhak mengubah lowongan ini' };

  const { title, description, category, location, status } = data;

  return prisma.jobPosting.update({
    where: { id: jobId },
    data: {
      ...(title && { title }),
      ...(description && { description }),
      ...(category && { category }),
      ...(location && { location }),
      ...(status && { status }),
    },
  });
}

export async function deleteJob(employerId, jobId) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });

  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.employerId !== employerId) throw { status: 403, message: 'Anda tidak berhak menghapus lowongan ini' };

  await prisma.jobPosting.delete({ where: { id: jobId } });
  return { message: 'Lowongan berhasil dihapus' };
}

export async function searchJobs({ page = 1, limit = 10, category, location, keyword }) {
  const skip = (page - 1) * limit;

  const where = {
    status: 'OPEN',
    ...(category && { category: { contains: category } }),
    ...(location && { location: { contains: location } }),
    ...(keyword && { title: { contains: keyword } }),
  };

  const [items, total] = await Promise.all([
    prisma.jobPosting.findMany({
      where,
      skip,
      take: Number(limit),
      orderBy: { createdAt: 'desc' },
      include: {
        employer: {
          select: { id: true, profile: { select: { fullName: true, photoUrl: true } } },
        },
      },
    }),
    prisma.jobPosting.count({ where }),
  ]);

  return {
    items,
    pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / limit) },
  };
}

export async function getJobDetail(jobId) {
  const job = await prisma.jobPosting.findUnique({
    where: { id: jobId },
    include: {
      employer: { select: { id: true, profile: { select: { fullName: true, photoUrl: true, location: true } } } },
    },
  });

  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  return job;
}

export async function getMyJobs(employerId) {
  return prisma.jobPosting.findMany({
    where: { employerId },
    orderBy: { createdAt: 'desc' },
    include: { _count: { select: { applications: true } } },
  });
}