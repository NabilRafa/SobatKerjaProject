import {
  applyToJob, getMyApplications,
  getApplicantsForJob, updateApplicationStatus,
} from './applicationService.js';

export async function apply(req, res) {
  try {
    const application = await applyToJob(req.user.id, req.body.jobId);
    return res.status(201).json(application);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function myApplications(req, res) {
  try {
    const applications = await getMyApplications(req.user.id);
    return res.status(200).json(applications);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function applicantsForJob(req, res) {
  try {
    const applicants = await getApplicantsForJob(req.user.id, req.params.jobId);
    return res.status(200).json(applicants);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function changeStatus(req, res) {
  try {
    const result = await updateApplicationStatus(req.user.id, req.params.id, req.body.status);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}