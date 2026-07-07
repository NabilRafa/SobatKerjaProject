import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import { apply, offer, myApplications, applicantsForJob, detail, respond, cancel } from './applicationController.js';

const router = Router();

router.post('/', verifyToken, verifyRole('WORKER'), apply);
router.post('/offer/job/:jobId', verifyToken, verifyRole('EMPLOYER'), offer);
router.get('/mine', verifyToken, verifyRole('WORKER'), myApplications);
router.get('/job/:jobId', verifyToken, verifyRole('EMPLOYER'), applicantsForJob);
router.get('/:id', verifyToken, detail);
router.patch('/:id/status', verifyToken, respond);
router.patch('/:id/cancel', verifyToken, verifyRole('WORKER'), cancel);

export default router;