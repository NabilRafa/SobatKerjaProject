import bcrypt from 'bcrypt';
import { prisma } from '../../config/db.js';
import { generateToken } from '../../utils/jwt.js';
import { generateOtp, getOtpExpiry } from '../../utils/otp.js';
import { sendOtpEmail } from '../../config/mailer.js';

export async function registerUser({ email, password, role, fullName }) {
  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) {
    throw { status: 409, message: 'Email sudah terdaftar' };
  }

  if (!['WORKER', 'EMPLOYER'].includes(role)) {
    throw { status: 400, message: 'Role tidak valid. Pilih WORKER atau EMPLOYER' };
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const otpCode = generateOtp();
  const otpExpiresAt = getOtpExpiry(10);

  const user = await prisma.user.create({
    data: {
      email,
      passwordHash,
      role,
      otpCode,
      otpExpiresAt,
      profile: { create: { fullName } },
    },
    include: { profile: true },
  });

  await sendOtpEmail(email, otpCode);

  return {
    message: 'Registrasi berhasil, silakan cek email untuk kode OTP verifikasi',
    email: user.email,
  };
}

export async function verifyOtp({ email, otpCode }) {
  const user = await prisma.user.findUnique({ where: { email } });

  if (!user) throw { status: 404, message: 'User tidak ditemukan' };
  if (user.isVerified) throw { status: 400, message: 'Akun sudah diverifikasi sebelumnya' };

  if (!user.otpCode || !user.otpExpiresAt) {
    throw { status: 400, message: 'Kode OTP tidak ditemukan, silakan minta kirim ulang' };
  }
  if (new Date() > user.otpExpiresAt) {
    throw { status: 400, message: 'Kode OTP sudah kadaluarsa, silakan minta kirim ulang' };
  }
  if (user.otpCode !== otpCode) {
    throw { status: 400, message: 'Kode OTP salah' };
  }

  const updatedUser = await prisma.user.update({
    where: { email },
    data: { isVerified: true, otpCode: null, otpExpiresAt: null },
    include: { profile: true },
  });

  const token = generateToken({ id: updatedUser.id, role: updatedUser.role });

  return { user: sanitizeUser(updatedUser), token };
}

export async function resendOtp(email) {
  const user = await prisma.user.findUnique({ where: { email } });

  if (!user) throw { status: 404, message: 'User tidak ditemukan' };
  if (user.isVerified) throw { status: 400, message: 'Akun sudah diverifikasi sebelumnya' };

  const otpCode = generateOtp();
  const otpExpiresAt = getOtpExpiry(10);

  await prisma.user.update({
    where: { email },
    data: { otpCode, otpExpiresAt },
  });

  await sendOtpEmail(email, otpCode);

  return { message: 'Kode OTP baru sudah dikirim ke email Anda' };
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

  if (!user.isVerified) {
    throw { status: 403, message: 'Akun belum diverifikasi, silakan cek OTP di email Anda' };
  }

  if (!user.isActive) {
    throw { status: 403, message: 'Akun Anda telah disuspend. Hubungi admin untuk informasi lebih lanjut' };
  }

  const token = generateToken({ id: user.id, role: user.role });

  return { user: sanitizeUser(user), token };
}

function sanitizeUser(user) {
  const { passwordHash, otpCode, otpExpiresAt, ...safeUser } = user;
  return safeUser;
}