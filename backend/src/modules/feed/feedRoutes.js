import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import { getFeed, getCvDetail } from './feedController.js';

const router = Router();

router.get('/', verifyToken, getFeed);
router.get('/:id', verifyToken, getCvDetail);

export default router;