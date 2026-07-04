import { prisma } from '../../config/db.js';

export async function addPortfolioItem(userId, imageUrl, caption) {
  return prisma.portfolio.create({
    data: { userId, imageUrl, caption: caption || null },
  });
}

export async function getPortfolioByUserId(userId) {
  return prisma.portfolio.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });
}

export async function deletePortfolioItem(userId, portfolioId) {
  const item = await prisma.portfolio.findUnique({ where: { id: portfolioId } });

  if (!item) throw { status: 404, message: 'Item portofolio tidak ditemukan' };
  if (item.userId !== userId) throw { status: 403, message: 'Anda tidak berhak menghapus item ini' };

  await prisma.portfolio.delete({ where: { id: portfolioId } });
  return { message: 'Item portofolio berhasil dihapus' };
}