import { Router } from 'express';
import { verifyToken, verifyRole } from '../../middleware/authMiddleware.js';
import { create, update, remove, myCvs, detail, publish, listTemplates } from './cvController.js';

const router = Router();

router.get('/templates', verifyToken, listTemplates);
router.get('/', verifyToken, verifyRole('WORKER'), myCvs);
router.get('/:id', verifyToken, verifyRole('WORKER'), detail);
router.post('/', verifyToken, verifyRole('WORKER'), create);
router.put('/:id', verifyToken, verifyRole('WORKER'), update);
router.delete('/:id', verifyToken, verifyRole('WORKER'), remove);
router.patch('/:id/publish', verifyToken, verifyRole('WORKER'), publish);

export default router;