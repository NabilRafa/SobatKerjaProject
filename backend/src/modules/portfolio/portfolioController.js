import { addPortfolioItem, getPortfolioByUserId, deletePortfolioItem } from './portfolioService.js';

export async function uploadPortfolio(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'File gambar wajib diupload' });
    }

    const item = await addPortfolioItem(req.user.id, req.file.path, req.body.caption);
    return res.status(201).json(item);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function myPortfolio(req, res) {
  try {
    const items = await getPortfolioByUserId(req.user.id);
    return res.status(200).json(items);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function removePortfolio(req, res) {
  try {
    const result = await deletePortfolioItem(req.user.id, req.params.id);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}