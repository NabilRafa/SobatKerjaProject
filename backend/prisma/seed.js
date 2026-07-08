import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const DEFAULT_USERS = [
  {
    email: 'worker@sobatkerja.com',
    password: 'worker123',
    role: 'WORKER',
    fullName: 'Budi Santoso',
    phone: '081234567890',
    location: 'Bandung',
    bio: 'Tukang bangunan berpengalaman 5 tahun',
    skills: ['Tukang Bangunan', 'Renovasi', 'Instalasi Listrik'],
  },
  {
    email: 'employer@sobatkerja.com',
    password: 'employer123',
    role: 'EMPLOYER',
    fullName: 'Siti Aminah',
    phone: '089876543210',
    location: 'Jakarta',
    bio: 'Pemilik rumah yang sering cari jasa perbaikan',
    skills: null,
  },
  {
    email: 'admin@sobatkerja.com',
    password: 'admin123',
    role: 'ADMIN',
    fullName: 'Admin SobatKerja',
    phone: null,
    location: null,
    bio: null,
    skills: null,
  },
];

async function main() {
  for (const u of DEFAULT_USERS) {
    const existing = await prisma.user.findUnique({ where: { email: u.email } });

    if (existing) {
      console.log(`Skip: ${u.email} sudah ada`);
      continue;
    }

    const passwordHash = await bcrypt.hash(u.password, 10);

    await prisma.user.create({
      data: {
        email: u.email,
        passwordHash,
        role: u.role,
        isVerified: true, // langsung verified, skip OTP
        profile: {
          create: {
            fullName: u.fullName,
            phone: u.phone,
            location: u.location,
            bio: u.bio,
            skills: u.skills,
          },
        },
      },
    });

    console.log(`Created: ${u.email} (${u.role}) / password: ${u.password}`);
  }
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });