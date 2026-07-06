/*
  Warnings:

  - Added the required column `contactName` to the `Application` table without a default value. This is not possible if the table is not empty.
  - Added the required column `contactPhone` to the `Application` table without a default value. This is not possible if the table is not empty.
  - Added the required column `salaryAmount` to the `JobPosting` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `application` ADD COLUMN `appliedSkill` VARCHAR(191) NULL,
    ADD COLUMN `contactName` VARCHAR(191) NOT NULL,
    ADD COLUMN `contactPhone` VARCHAR(191) NOT NULL,
    ADD COLUMN `portfolioUrls` JSON NULL;

-- AlterTable
ALTER TABLE `jobposting` ADD COLUMN `requirements` JSON NULL,
    ADD COLUMN `salaryAmount` DECIMAL(12, 2) NOT NULL,
    ADD COLUMN `salaryType` ENUM('PER_HARI', 'PER_BULAN') NOT NULL DEFAULT 'PER_HARI';
