import nodemailer from 'nodemailer';
import dotenv from 'dotenv';

dotenv.config();

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

export async function sendOtpEmail(toEmail, otpCode) {
  await transporter.sendMail({
    from: `"Sobat Kerja" <${process.env.EMAIL_USER}>`,
    to: toEmail,
    subject: 'Kode Verifikasi Akun Sobat Kerja',
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Verifikasi Akun Anda</h2>
        <p>Gunakan kode berikut untuk verifikasi akun Sobat Kerja Anda:</p>
        <h1 style="letter-spacing: 4px;">${otpCode}</h1>
        <p>Kode ini berlaku selama 10 menit. Jangan bagikan kode ini kepada siapapun.</p>
      </div>
    `,
  });
}