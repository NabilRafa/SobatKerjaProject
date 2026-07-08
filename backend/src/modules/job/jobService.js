import { prisma } from '../../config/db.js';

function withAvailableSlot(job) {
  return { ...job, availableSlot: Math.max(job.totalSlot - job.filledSlot, 0) };
}

export async function createJob(employerId, data) {
  const {
    title, description, locationArea, fullAddress,
    totalSlot, salaryAmount, salaryType, requirements,
  } = data;

  if (!title || !description || !locationArea || !fullAddress || !salaryAmount) {
    throw { status: 400, message: 'Semua field wajib diisi, termasuk lokasi dan gaji' };
  }

  return prisma.jobPosting.create({
    data: {
      employerId,
      title,
      description,
      locationArea,
      fullAddress,
      totalSlot: totalSlot ? Number(totalSlot) : 1,
      salaryAmount: Number(salaryAmount),
      salaryType: salaryType || 'PER_HARI',
      requirements: requirements || [],
    },
  });
}

export async function updateJob(employerId, jobId, data) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });

  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.employerId !== employerId) throw { status: 403, message: 'Anda tidak berhak mengubah lowongan ini' };

  const {
    title, description, locationArea, fullAddress, status,
    salaryAmount, salaryType, requirements,
  } = data;

  return prisma.jobPosting.update({
    where: { id: jobId },
    data: {
      ...(title && { title }),
      ...(description && { description }),
      ...(locationArea && { locationArea }),
      ...(fullAddress && { fullAddress }),
      ...(status && { status }),
      ...(salaryAmount && { salaryAmount: Number(salaryAmount) }),
      ...(salaryType && { salaryType }),
      ...(requirements && { requirements }),
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

export async function searchJobs({ page = 1, limit = 10, locationArea, keyword }) {
  const skip = (page - 1) * limit;

  const where = {
    status: 'OPEN',
    ...(locationArea && { locationArea: { contains: locationArea } }),
    ...(keyword && { title: { contains: keyword } }),
  };

  const [items, total] = await Promise.all([
    prisma.jobPosting.findMany({
      where,
      skip,
      take: Number(limit),
      orderBy: { createdAt: 'desc' },
      include: {
        employer: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } },
      },
    }),
    prisma.jobPosting.count({ where }),
  ]);

  return {
    items: items.map(withAvailableSlot),
    pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / limit) },
  };
}

export async function getMyJobs(employerId) {
  const jobs = await prisma.jobPosting.findMany({
    where: { employerId },
    orderBy: { createdAt: 'desc' },
    include: { _count: { select: { applications: true } } },
  });

  return jobs.map(withAvailableSlot);
}

export async function getRecommendedJobs(workerId, { page = 1, limit = 10 }) {
  const profile = await prisma.profile.findUnique({ where: { userId: workerId } });
  const skills = profile?.skills;

  if (!Array.isArray(skills) || skills.length === 0) {
    throw { status: 400, message: 'Anda belum mengisi keahlian di profil, silakan lengkapi dulu' };
  }

  const textMatchConditions = skills.flatMap((skill) => ([
    { title: { contains: skill } },
    { description: { contains: skill } },
  ]));

  const [items, total] = await Promise.all([
    prisma.jobPosting.findMany({
      where: { status: 'OPEN', OR: textMatchConditions },
      skip: (page - 1) * limit,
      take: Number(limit),
      orderBy: { createdAt: 'desc' },
      include: { employer: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } } },
    }),
    prisma.jobPosting.count({ where: { status: 'OPEN', OR: textMatchConditions } }),
  ]);

  return {
    items: items.map(withAvailableSlot),
    pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / limit) },
  };
}
export async function getJobDetail(jobId, currentUserId) {
  const job = await prisma.jobPosting.findUnique({
    where: { id: jobId },
    include: {
      employer: {
        select: { id: true, profile: { select: { fullName: true, photoUrl: true, location: true } } },
      },
    },
  });

  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };

  const employerRatingAgg = await prisma.rating.aggregate({
    where: { toUserId: job.employerId },
    _avg: { score: true },
    _count: { score: true },
  });

  let myApplication = null;
  if (currentUserId) {
    myApplication = await prisma.application.findUnique({
      where: { jobId_applicantId: { jobId, applicantId: currentUserId } },
      select: { id: true, status: true, type: true },
    });
  }

  return {
    ...withAvailableSlot(job),
    employer: {
      ...job.employer,
      rating: {
        average: employerRatingAgg._avg.score ? Math.round(employerRatingAgg._avg.score * 10) / 10 : 0,
        total: employerRatingAgg._count.score,
      },
    },
    myApplication,
  };
}