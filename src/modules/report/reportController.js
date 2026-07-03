import { createReport, getMyReports } from './reportService.js';

export async function submitReport(req, res) {
  try {
    const report = await createReport(req.user.id, req.body);
    return res.status(201).json(report);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function myReports(req, res) {
  try {
    const reports = await getMyReports(req.user.id);
    return res.status(200).json(reports);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}