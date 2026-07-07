import {
  applyToJob, createOffer, getMyApplications,
  getApplicantsForJob, getApplicationDetail,
  respondToApplication, cancelApplication,
} from './applicationService.js';

export async function apply(req, res) {
  try {
    const application = await applyToJob(req.user.id, req.body.jobId, req.body);
    return res.status(201).json(application);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function offer(req, res) {
  try {
    const application = await createOffer(req.user.id, req.params.jobId, req.body.workerId);
    return res.status(201).json(application);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function myApplications(req, res) {
  try {
    const { type, keyword } = req.query;
    const applications = await getMyApplications(req.user.id, type, keyword);
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

export async function detail(req, res) {
  try {
    const result = await getApplicationDetail(req.user.id, req.params.id);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function respond(req, res) {
  try {
    const result = await respondToApplication(req.user.id, req.params.id, req.body.status);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function cancel(req, res) {
  try {
    const result = await cancelApplication(req.user.id, req.params.id);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}