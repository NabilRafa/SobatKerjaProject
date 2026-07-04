import {
  createJob, updateJob, deleteJob,
  searchJobs, getJobDetail, getMyJobs,
} from './jobService.js';

export async function create(req, res) {
  try {
    const job = await createJob(req.user.id, req.body);
    return res.status(201).json(job);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function update(req, res) {
  try {
    const job = await updateJob(req.user.id, req.params.id, req.body);
    return res.status(200).json(job);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function remove(req, res) {
  try {
    const result = await deleteJob(req.user.id, req.params.id);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function search(req, res) {
  try {
    const result = await searchJobs(req.query);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function detail(req, res) {
  try {
    const job = await getJobDetail(req.params.id);
    return res.status(200).json(job);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function myJobs(req, res) {
  try {
    const jobs = await getMyJobs(req.user.id);
    return res.status(200).json(jobs);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}