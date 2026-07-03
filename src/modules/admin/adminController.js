import {
  getAllReports, updateReportStatus, getAllUsers,
  toggleUserActive, takedownCv, takedownJob,
} from './adminService.js';

export async function listReports(req, res) {
  try {
    const reports = await getAllReports(req.query.status);
    return res.status(200).json(reports);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function reviewReport(req, res) {
  try {
    const report = await updateReportStatus(req.params.id, req.body.status);
    return res.status(200).json(report);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function listUsers(req, res) {
  try {
    const users = await getAllUsers();
    return res.status(200).json(users);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function suspendUser(req, res) {
  try {
    const user = await toggleUserActive(req.params.id, false);
    return res.status(200).json(user);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function activateUser(req, res) {
  try {
    const user = await toggleUserActive(req.params.id, true);
    return res.status(200).json(user);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function removeCv(req, res) {
  try {
    const cv = await takedownCv(req.params.id);
    return res.status(200).json(cv);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function removeJob(req, res) {
  try {
    const job = await takedownJob(req.params.id);
    return res.status(200).json(job);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}