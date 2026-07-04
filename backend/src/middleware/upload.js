import multer from 'multer';
import { CloudinaryStorage } from 'multer-storage-cloudinary';
import cloudinary from '../config/cloudinary.js';

function createUploader(folder) {
  const storage = new CloudinaryStorage({
    cloudinary,
    params: {
      folder,
      allowed_formats: ['jpg', 'jpeg', 'png'],
      transformation: [{ width: 1000, height: 1000, crop: 'limit' }],
    },
  });

  return multer({ storage, limits: { fileSize: 2 * 1024 * 1024 } });
}

export const uploadProfilePhoto = createUploader('sobat_kerja/profile_photos');
export const uploadPortfolioPhoto = createUploader('sobat_kerja/portfolio');