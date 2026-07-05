import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import { provinces, regencies, skills } from './masterdataController.js';

const router = Router();

router.get('/provinces', verifyToken, provinces);
router.get('/regencies/:provinceId', verifyToken, regencies);
router.get('/skills', verifyToken, skills);

export default router;