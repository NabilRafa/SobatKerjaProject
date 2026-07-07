import { prisma } from '../../config/db.js';

const VALID_TARGET_TYPES = ['USER', 'CV', 'JOB_POSTING', 'MESSAGE'];

const REPORT_CATEGORIES = [
  { id: 'PENIPUAN', label: 'Penipuan atau scam' },
  { id: 'KONTEN_TIDAK_PANTAS', label: 'Konten tidak pantas' },
  { id: 'INFORMASI_PALSU', label: 'Informasi palsu atau menyesatkan' },
  { id: 'PELECEHAN', label: 'Pelecehan atau kata-kata kasar' },
  { id: 'SPAM', label: 'Spam' },
  { id: 'LAINNYA', label: 'Lainnya' },
];

export function getReportCategories() {
  return REPORT_CATEGORIES;
}

export async function createReport(reporterId, { targetType, targetId, category, description }) {
  if (!VALID_TARGET_TYPES.includes(targetType)) {
    throw { status: 400, message: 'Tipe target tidak valid' };
  }
  if (!targetId) {
    throw { status: 400, message: 'targetId wajib diisi' };
  }

  const validCategoryIds = REPORT_CATEGORIES.map(c => c.id);
  if (!validCategoryIds.includes(category)) {
    throw { status: 400, message: 'Alasan laporan tidak valid' };
  }

  return prisma.report.create({
    data: { reporterId, targetType, targetId, category, description: description || null },
  });
}

export async function getMyReports(reporterId) {
  return prisma.report.findMany({
    where: { reporterId },
    orderBy: { createdAt: 'desc' },
  });
}