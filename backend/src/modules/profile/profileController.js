import { getProfileByUserId, getPublicProfileByUserId, updateProfile, updateProfilePhoto } from './profileService.js';

export async function getMyProfile(req, res) {
  try {
    const profile = await getProfileByUserId(req.user.id);
    return res.status(200).json(profile);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function getPublicProfile(req, res) {
  try {
    const profile = await getPublicProfileByUserId(req.params.userId);
    return res.status(200).json(profile);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function updateMyProfile(req, res) {
  try {
    const updated = await updateProfile(req.user.id, req.body);
    return res.status(200).json(updated);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function uploadMyPhoto(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'File foto wajib diupload' });
    }

    const updated = await updateProfilePhoto(req.user.id, req.file.path);
    return res.status(200).json(updated);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}