import { registerUser, loginUser, verifyOtp, resendOtp } from './authService.js';

export async function register(req, res) {
  try {
    const { email, password, role, fullName } = req.body;

    if (!email || !password || !role || !fullName) {
      return res.status(400).json({ message: 'Semua field wajib diisi' });
    }

    const result = await registerUser({ email, password, role, fullName });
    return res.status(201).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function verify(req, res) {
  try {
    const { email, otpCode } = req.body;

    if (!email || !otpCode) {
      return res.status(400).json({ message: 'Email dan kode OTP wajib diisi' });
    }

    const result = await verifyOtp({ email, otpCode });
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function resend(req, res) {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: 'Email wajib diisi' });

    const result = await resendOtp(email);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email dan password wajib diisi' });
    }

    const result = await loginUser({ email, password });
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}