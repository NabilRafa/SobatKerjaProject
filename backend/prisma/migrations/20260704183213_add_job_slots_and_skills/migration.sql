-- AlterTable
ALTER TABLE `jobposting` ADD COLUMN `filledSlot` INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN `requiredSkills` JSON NULL,
    ADD COLUMN `totalSlot` INTEGER NOT NULL DEFAULT 1;
