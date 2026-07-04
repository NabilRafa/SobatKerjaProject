import { createRating, getUserRatings } from './ratingService.js';

export async function submitRating(req, res) {
  try {
    const rating = await createRating(req.user.id, req.params.applicationId, req.body);
    return res.status(201).json(rating);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function getRatings(req, res) {
  try {
    const result = await getUserRatings(req.params.userId);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}