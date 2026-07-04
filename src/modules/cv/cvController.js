import { upsertCv, getMyCv, togglePublish } from './cvService.js';

export async function createOrUpdateCv(req, res) {
  try {
    const cv = await upsertCv(req.user.id, req.body);
    return res.status(200).json(cv);
  } catch (err) {
    console.error('CV generate error:', err.message || err);
    return res.status(err.status || 500).json({ message: err.message || 'Gagal generate CV' });
  }
}

export async function getMyCvController(req, res) {
  try {
    const cv = await getMyCv(req.user.id);
    return res.status(200).json(cv);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function publishCv(req, res) {
  try {
    const { isPublished } = req.body;
    const cv = await togglePublish(req.user.id, Boolean(isPublished));
    return res.status(200).json(cv);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}