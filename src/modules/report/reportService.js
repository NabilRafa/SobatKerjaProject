import { prisma } from '../../config/db.js';

const VALID_TARGET_TYPES = ['USER', 'CV', 'JOB_POSTING', 'MESSAGE'];

export async function createReport(reporterId, { targetType, targetId, reason }) {
  if (!VALID_TARGET_TYPES.includes(targetType)) {
    throw { status: 400, message: 'Tipe target tidak valid' };
  }
  if (!targetId || !reason) {
    throw { status: 400, message: 'targetId dan reason wajib diisi' };
  }

  return prisma.report.create({
    data: { reporterId, targetType, targetId, reason },
  });
}

export async function getMyReports(reporterId) {
  return prisma.report.findMany({
    where: { reporterId },
    orderBy: { createdAt: 'desc' },
  });
}