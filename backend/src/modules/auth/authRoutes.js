import { Router } from 'express';
import { register, login, verify, resend } from './authController.js';

const router = Router();

router.post('/register', register);
router.post('/verify-otp', verify);
router.post('/resend-otp', resend);
router.post('/login', login);

export default router;