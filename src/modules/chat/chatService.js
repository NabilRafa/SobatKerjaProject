import { prisma } from '../../config/db.js';

export async function getOrCreateConversation(userId, otherUserId) {
  if (userId === otherUserId) {
    throw { status: 400, message: 'Tidak bisa membuat percakapan dengan diri sendiri' };
  }

  const otherUser = await prisma.user.findUnique({ where: { id: otherUserId } });
  if (!otherUser) throw { status: 404, message: 'User tujuan tidak ditemukan' };

  const existing = await prisma.conversation.findFirst({
    where: {
      AND: [
        { members: { some: { userId } } },
        { members: { some: { userId: otherUserId } } },
      ],
    },
  });

  if (existing) return existing;

  return prisma.conversation.create({
    data: {
      members: {
        create: [{ userId }, { userId: otherUserId }],
      },
    },
  });
}

export async function getMyConversations(userId) {
  const conversations = await prisma.conversation.findMany({
    where: { members: { some: { userId } } },
    orderBy: { createdAt: 'desc' },
    include: {
      members: {
        where: { userId: { not: userId } },
        include: { user: { select: { id: true, profile: { select: { fullName: true, photoUrl: true } } } } },
      },
      messages: { orderBy: { createdAt: 'desc' }, take: 1 },
    },
  });

  return conversations.map(conv => ({
    conversationId: conv.id,
    otherUser: conv.members[0]?.user,
    lastMessage: conv.messages[0] || null,
  }));
}

export async function sendMessage(senderId, conversationId, content) {
  const membership = await prisma.conversationMember.findUnique({
    where: { conversationId_userId: { conversationId, userId: senderId } },
  });

  if (!membership) throw { status: 403, message: 'Anda bukan anggota percakapan ini' };
  if (!content || content.trim() === '') throw { status: 400, message: 'Pesan tidak boleh kosong' };

  return prisma.message.create({
    data: { conversationId, senderId, content: content.trim() },
  });
}

export async function getMessages(userId, conversationId, since) {
  const membership = await prisma.conversationMember.findUnique({
    where: { conversationId_userId: { conversationId, userId } },
  });

  if (!membership) throw { status: 403, message: 'Anda bukan anggota percakapan ini' };

  const where = {
    conversationId,
    ...(since && { createdAt: { gt: new Date(since) } }),
  };

  return prisma.message.findMany({
    where,
    orderBy: { createdAt: 'asc' },
    include: { sender: { select: { id: true, profile: { select: { fullName: true } } } } },
  });
}