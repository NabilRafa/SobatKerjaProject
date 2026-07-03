import { registerUser, loginUser } from './authService.js';

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