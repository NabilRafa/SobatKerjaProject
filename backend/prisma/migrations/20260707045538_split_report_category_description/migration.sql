/*
  Warnings:

  - You are about to drop the column `reason` on the `report` table. All the data in the column will be lost.
  - Added the required column `category` to the `Report` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `report` DROP COLUMN `reason`,
    ADD COLUMN `category` VARCHAR(191) NOT NULL,
    ADD COLUMN `description` TEXT NULL;
