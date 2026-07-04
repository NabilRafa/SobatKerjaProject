import { getPublishedCvFeed, getCvDetailById } from './feedService.js';

export async function getFeed(req, res) {
  try {
    const { page, limit, location } = req.query;
    const result = await getPublishedCvFeed({ page, limit, location });
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function getCvDetail(req, res) {
  try {
    const cv = await getCvDetailById(req.params.id);
    return res.status(200).json(cv);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}