/*
  Warnings:

  - Added the required column `cvId` to the `Application` table without a default value. This is not possible if the table is not empty.
  - Added the required column `label` to the `CV` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE `cv` DROP FOREIGN KEY `CV_userId_fkey`;

-- DropIndex
DROP INDEX `CV_userId_key` ON `cv`;

-- AlterTable
ALTER TABLE `application` ADD COLUMN `cvId` VARCHAR(191) NOT NULL;

-- AlterTable
ALTER TABLE `cv` ADD COLUMN `label` VARCHAR(191) NOT NULL;

-- AddForeignKey
ALTER TABLE `Application` ADD CONSTRAINT `Application_cvId_fkey` FOREIGN KEY (`cvId`) REFERENCES `CV`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
