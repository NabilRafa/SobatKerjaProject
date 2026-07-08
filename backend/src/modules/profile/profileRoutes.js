import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import { uploadProfilePhoto } from '../../middleware/upload.js';
import { getMyProfile, updateMyProfile, uploadMyPhoto, getPublicProfile, searchWorkers } from './profileController.js';

const router = Router();

router.get('/me', verifyToken, getMyProfile);
router.put('/me', verifyToken, updateMyProfile);
router.post('/me/photo', verifyToken, uploadProfilePhoto.single('photo'), uploadMyPhoto);
router.get('/search/workers', verifyToken, verifyRole('EMPLOYER'), searchWorkers);
router.get('/:userId', verifyToken, getPublicProfile);

export default router;