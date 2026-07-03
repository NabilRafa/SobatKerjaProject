import { prisma } from '../../config/db.js';

export async function getAllReports(status) {
  return prisma.report.findMany({
    where: status ? { status } : {},
    orderBy: { createdAt: 'desc' },
    include: {
      reporter: { select: { id: true, email: true, profile: { select: { fullName: true } } } },
    },
  });
}

export async function updateReportStatus(reportId, status) {
  const validStatuses = ['PENDING', 'REVIEWED', 'RESOLVED'];
  if (!validStatuses.includes(status)) {
    throw { status: 400, message: 'Status tidak valid' };
  }

  const report = await prisma.report.findUnique({ where: { id: reportId } });
  if (!report) throw { status: 404, message: 'Laporan tidak ditemukan' };

  return prisma.report.update({ where: { id: reportId }, data: { status } });
}

export async function getAllUsers() {
  return prisma.user.findMany({
    orderBy: { createdAt: 'desc' },
    select: {
      id: true, email: true, role: true, isActive: true, createdAt: true,
      profile: { select: { fullName: true } },
    },
  });
}

export async function toggleUserActive(userId, isActive) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw { status: 404, message: 'User tidak ditemukan' };

  return prisma.user.update({ where: { id: userId }, data: { isActive } });
}

export async function takedownCv(cvId) {
  const cv = await prisma.cV.findUnique({ where: { id: cvId } });
  if (!cv) throw { status: 404, message: 'CV tidak ditemukan' };

  return prisma.cV.update({ where: { id: cvId }, data: { isPublished: false } });
}

export async function takedownJob(jobId) {
  const job = await prisma.jobPosting.findUnique({ where: { id: jobId } });
  if (!job) throw { status: 404, message: 'Lowongan tidak ditemukan' };

  return prisma.jobPosting.update({ where: { id: jobId }, data: { status: 'CLOSED' } });
}