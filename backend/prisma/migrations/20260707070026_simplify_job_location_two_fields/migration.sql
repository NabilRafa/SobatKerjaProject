/*
  Warnings:

  - You are about to drop the column `category` on the `jobposting` table. All the data in the column will be lost.
  - You are about to drop the column `location` on the `jobposting` table. All the data in the column will be lost.
  - Added the required column `fullAddress` to the `JobPosting` table without a default value. This is not possible if the table is not empty.
  - Added the required column `locationArea` to the `JobPosting` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `jobposting` DROP COLUMN `category`,
    DROP COLUMN `location`,
    ADD COLUMN `fullAddress` TEXT NOT NULL,
    ADD COLUMN `locationArea` VARCHAR(191) NOT NULL;
