import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import { apply, myApplications, applicantsForJob, changeStatus } from './applicationController.js';

const router = Router();

router.post('/', verifyToken, verifyRole('WORKER'), apply);
router.get('/mine', verifyToken, verifyRole('WORKER'), myApplications);
router.get('/job/:jobId', verifyToken, verifyRole('EMPLOYER'), applicantsForJob);
router.patch('/:id/status', verifyToken, verifyRole('EMPLOYER'), changeStatus);

export default router;