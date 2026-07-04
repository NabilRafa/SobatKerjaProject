-- AlterTable
ALTER TABLE `user` ADD COLUMN `isVerified` BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN `otpCode` VARCHAR(6) NULL,
    ADD COLUMN `otpExpiresAt` DATETIME(3) NULL;
