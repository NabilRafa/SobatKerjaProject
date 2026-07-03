import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import authRoutes from './src/modules/auth/authRoutes.js';
import profileRoutes from './src/modules/profile/profileRoutes.js';
import cvRoutes from './src/modules/cv/cvRoutes.js';
import feedRoutes from './src/modules/feed/feedRoutes.js';
import jobRoutes from './src/modules/job/jobRoutes.js';
import applicationRoutes from './src/modules/application/applicationRoutes.js';
import chatRoutes from './src/modules/chat/chatRoutes.js';
import ratingRoutes from './src/modules/rating/ratingRoutes.js';
import reportRoutes from './src/modules/report/reportRoutes.js';
import adminRoutes from './src/modules/admin/adminRoutes.js';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use('/api/auth', authRoutes);

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});

app.use('/api/profile', profileRoutes);
app.use('/api/cv', cvRoutes);
app.use('/api/feed', feedRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/ratings', ratingRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/admin', adminRoutes);