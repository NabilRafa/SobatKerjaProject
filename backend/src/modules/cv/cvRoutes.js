import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import { createOrUpdateCv, getMyCvController, publishCv, listTemplates } from './cvController.js';

const router = Router();

router.get('/templates', verifyToken, listTemplates);
router.post('/', verifyToken, verifyRole('WORKER'), createOrUpdateCv);
router.get('/me', verifyToken, getMyCvController);
router.patch('/publish', verifyToken, verifyRole('WORKER'), publishCv);

export default router;