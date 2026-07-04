import { Router } from 'express';
import { verifyToken } from '../../middleware/authMiddleware.js';
import { startConversation, myConversations, postMessage, pollMessages } from './chatController.js';

const router = Router();

router.post('/conversations', verifyToken, startConversation);
router.get('/conversations', verifyToken, myConversations);
router.post('/conversations/:conversationId/messages', verifyToken, postMessage);
router.get('/conversations/:conversationId/messages', verifyToken, pollMessages);

export default router;