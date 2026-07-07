import { createCv, updateCv, deleteCv, getMyCvs, getCvById, togglePublish, previewCv } from './cvService.js';
import { getAvailableTemplates } from './cvTemplates.js';

export async function create(req, res) {
  try {
    const { label, templateId, ...dataJson } = req.body;
    const cv = await createCv(req.user.id, label, dataJson, templateId);
    return res.status(201).json(cv);
  } catch (err) {
    console.error('CV create error:', err.message || err);
    return res.status(err.status || 500).json({ message: err.message || 'Gagal membuat CV' });
  }
}

export async function update(req, res) {
  try {
    const { label, templateId, ...dataJson } = req.body;
    const cv = await updateCv(req.user.id, req.params.id, {
      label,
      templateId,
      dataJson: Object.keys(dataJson).length ? dataJson : undefined,
    });
    return res.status(200).json(cv);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function remove(req, res) {
  try {
    const result = await deleteCv(req.user.id, req.params.id);
    return res.status(200).json(result);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function myCvs(req, res) {
  try {
    const cvs = await getMyCvs(req.user.id);
    return res.status(200).json(cvs);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function detail(req, res) {
  try {
    const cv = await getCvById(req.user.id, req.params.id);
    return res.status(200).json(cv);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function publish(req, res) {
  try {
    const cv = await togglePublish(req.user.id, req.params.id, Boolean(req.body.isPublished));
    return res.status(200).json(cv);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Terjadi kesalahan server' });
  }
}

export async function listTemplates(req, res) {
  return res.status(200).json(getAvailableTemplates());
}

export async function preview(req, res) {
  try {
    const { templateId, ...dataJson } = req.body;
    const pdfBuffer = await previewCv(req.user.id, templateId, dataJson);

    res.set('Content-Type', 'application/pdf');
    res.set('Content-Disposition', 'inline; filename="preview-cv.pdf"');
    return res.status(200).send(pdfBuffer);
  } catch (err) {
    return res.status(err.status || 500).json({ message: err.message || 'Gagal membuat preview CV' });
  }
}