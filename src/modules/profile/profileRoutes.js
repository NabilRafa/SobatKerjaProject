import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import upload from '../../middleware/upload.js';
import { getMyProfile, updateMyProfile, uploadMyPhoto } from './profileController.js';

const router = Router();

router.get('/me', verifyToken, getMyProfile);
router.put('/me', verifyToken, updateMyProfile);
router.post('/me/photo', verifyToken, upload.single('photo'), uploadMyPhoto);

export default router;