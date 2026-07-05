/*
  Warnings:

  - A unique constraint covering the columns `[applicationId,fromUserId]` on the table `Rating` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE `rating` DROP FOREIGN KEY `Rating_applicationId_fkey`;

-- DropIndex
DROP INDEX `Rating_applicationId_key` ON `rating`;

-- CreateIndex
CREATE UNIQUE INDEX `Rating_applicationId_fromUserId_key` ON `Rating`(`applicationId`, `fromUserId`);

-- AddForeignKey
ALTER TABLE `Rating` ADD CONSTRAINT `Rating_applicationId_fkey` FOREIGN KEY (`applicationId`) REFERENCES `Application`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
