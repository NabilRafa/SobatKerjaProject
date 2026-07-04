import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import { uploadPortfolioPhoto } from '../../middleware/upload.js';
import { uploadPortfolio, myPortfolio, removePortfolio } from './portfolioController.js';

const router = Router();

router.post('/', verifyToken, verifyRole('WORKER'), uploadPortfolioPhoto.single('image'), uploadPortfolio);
router.get('/mine', verifyToken, verifyRole('WORKER'), myPortfolio);
router.delete('/:id', verifyToken, verifyRole('WORKER'), removePortfolio);

export default router;