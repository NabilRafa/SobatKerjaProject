import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import { submitRating, getRatings } from './ratingController.js';

const router = Router();

router.post('/application/:applicationId', verifyToken, submitRating);
router.get('/user/:userId', verifyToken, getRatings);

export default router;