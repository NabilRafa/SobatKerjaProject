import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import { create, update, remove, search, detail, myJobs } from './jobController.js';

const router = Router();

router.get('/', verifyToken, search);
router.get('/mine', verifyToken, verifyRole('EMPLOYER'), myJobs);
router.get('/:id', verifyToken, detail);
router.post('/', verifyToken, verifyRole('EMPLOYER'), create);
router.put('/:id', verifyToken, verifyRole('EMPLOYER'), update);
router.delete('/:id', verifyToken, verifyRole('EMPLOYER'), remove);

export default router;