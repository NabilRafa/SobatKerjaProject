/*
  Warnings:

  - You are about to drop the column `cvId` on the `application` table. All the data in the column will be lost.
  - Added the required column `cvIds` to the `Application` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE `application` DROP FOREIGN KEY `Application_cvId_fkey`;

-- DropIndex
DROP INDEX `Application_cvId_fkey` ON `application`;

-- AlterTable
ALTER TABLE `application` DROP COLUMN `cvId`,
    ADD COLUMN `cvIds` JSON NOT NULL;
