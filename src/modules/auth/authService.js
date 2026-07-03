import bcrypt from 'bcrypt';
import { prisma } from '../../config/db.js';
import { generateToken } from '../../utils/jwt.js';

export async function registerUser({ email, password, role, fullName }) {
  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) {
    throw { status: 409, message: 'Email sudah terdaftar' };
  }

  if (!['WORKER', 'EMPLOYER'].includes(role)) {
    throw { status: 400, message: 'Role tidak valid. Pilih WORKER atau EMPLOYER' };
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await prisma.user.create({
    data: {
      email,
      passwordHash,
      role,
      profile: {
        create: { fullName },
      },
    },
    include: { profile: true },
  });

  const token = generateToken({ id: user.id, role: user.role });

  return { user: sanitizeUser(user), token };
}

export async function loginUser({ email, password }) {
  const user = await prisma.user.findUnique({
    where: { email },
    include: { profile: true },
  });

  if (!user) {
    throw { status: 401, message: 'Email atau password salah' };
  }

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
  if (!isPasswordValid) {
    throw { status: 401, message: 'Email atau password salah' };
  }

  const token = generateToken({ id: user.id, role: user.role });

  return { user: sanitizeUser(user), token };
}

function sanitizeUser(user) {
  const { passwordHash, ...safeUser } = user;
  return safeUser;
}