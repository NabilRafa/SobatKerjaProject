import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import {
  listReports, reviewReport, listUsers,
  suspendUser, activateUser, removeCv, removeJob,
} from './adminController.js';

const router = Router();

router.use(verifyToken, verifyRole('ADMIN'));

router.get('/reports', listReports);
router.patch('/reports/:id', reviewReport);
router.get('/users', listUsers);
router.patch('/users/:id/suspend', suspendUser);
router.patch('/users/:id/activate', activateUser);
router.patch('/cv/:id/takedown', removeCv);
router.patch('/jobs/:id/takedown', removeJob);

export default router;