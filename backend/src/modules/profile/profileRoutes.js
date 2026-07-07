import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import { uploadProfilePhoto } from '../../middleware/upload.js';
import { getMyProfile, updateMyProfile, uploadMyPhoto, getPublicProfile } from './profileController.js';

const router = Router();

router.get('/me', verifyToken, getMyProfile);
router.put('/me', verifyToken, updateMyProfile);
router.post('/me/photo', verifyToken, uploadProfilePhoto.single('photo'), uploadMyPhoto);
router.get('/:userId', verifyToken, getPublicProfile);

export default router;