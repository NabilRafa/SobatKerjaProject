import { getProvinces, getRegencies, getPredefinedSkills } from './masterdataService.js';

export function provinces(req, res) {
  return res.status(200).json(getProvinces());
}

export function regencies(req, res) {
  try {
    const data = getRegencies(req.params.provinceId);
    return res.status(200).json(data);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export function skills(req, res) {
  return res.status(200).json(getPredefinedSkills());
}