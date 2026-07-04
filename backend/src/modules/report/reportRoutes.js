import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import { submitReport, myReports } from './reportController.js';

const router = Router();

router.post('/', verifyToken, submitReport);
router.get('/mine', verifyToken, myReports);

export default router;