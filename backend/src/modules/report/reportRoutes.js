import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import { submitReport, myReports, listCategories } from './reportController.js';

const router = Router();

router.get('/categories', verifyToken, listCategories);
router.post('/', verifyToken, submitReport);
router.get('/mine', verifyToken, myReports);

export default router;