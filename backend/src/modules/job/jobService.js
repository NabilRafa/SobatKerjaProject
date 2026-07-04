import { prisma } from '../../config/db.js';

function withAvailableSlot(job) {
  return { ...job, availableSlot: Math.max(job.totalSlot - job.filledSlot, 0) };
}

export async function createJob(employerId, data) {
  const { title, description, category, location, totalSlot, requiredSkills } = data;

  if (!title || !description || !category || !location) {
    throw { status: 400, message: 'Semua field wajib diisi' };
  }

  return prisma.jobPosting.create({
    data: {
      employerId,
      title,
      description,
      category,
      location,
      totalSlot: totalSlot ? Number(totalSlot) : 1,
      requiredSkills: requiredSkills || [],
    },
  });
}

export async function updateJob(employerId, jobId, data) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });

  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };
  if (job.employerId !== employerId) throw { status: 403, message: 'Anda tidak berhak mengubah lowongan ini' };

  const { title, description, category, location, status, requiredSkills } = data;

  return prisma.jobPosting.update({
    where: { id: jobId },
    data: {
      ...(title && { title }),
      ...(description && { description }),
      ...(category && { category }),
      ...(location && { location }),
      ...(status && { status }),
      ...(requiredSkills && { requiredSkills }),
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
    items: items.map(withAvailableSlot),
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
  return withAvailableSlot(job);
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
    { category: { contains: skill } },
    { title: { contains: skill } },
    { description: { contains: skill } },
  ]));

  const [textMatchJobs, allOpenJobs] = await Promise.all([
    prisma.jobPosting.findMany({
      where: { status: 'OPEN', OR: textMatchConditions },
      include: { employer: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } } },
    }),
    prisma.jobPosting.findMany({
      where: { status: 'OPEN' },
      include: { employer: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } } },
    }),
  ]);

  const skillMatchJobs = allOpenJobs.filter((job) => {
    const required = Array.isArray(job.requiredSkills) ? job.requiredSkills : [];
    return required.some((reqSkill) => skills.includes(reqSkill));
  });

  const merged = new Map();
  [...textMatchJobs, ...skillMatchJobs].forEach((job) => merged.set(job.id, job));

  const allMatches = Array.from(merged.values()).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  const total = allMatches.length;
  const skip = (page - 1) * limit;
  const items = allMatches.slice(skip, skip + Number(limit)).map(withAvailableSlot);

  return {
    items,
    pagination: { page: Number(page), limit: Number(limit), total, totalPages: Math.ceil(total / limit) },
  };
}