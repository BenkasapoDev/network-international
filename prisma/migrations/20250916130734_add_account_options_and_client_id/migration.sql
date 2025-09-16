/*
  Warnings:

  - You are about to drop the column `accountIdentifier` on the `account` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[accountNumber]` on the table `Account` will be added. If there are existing duplicate values, this will fail.
  - A unique constraint covering the columns `[externalAccountId]` on the table `Account` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `accountNumber` to the `Account` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX `Account_accountIdentifier_key` ON `account`;

-- DropIndex
DROP INDEX `Account_clientId_fkey` ON `account`;

-- DropIndex
DROP INDEX `Address_clientId_fkey` ON `address`;

-- DropIndex
DROP INDEX `Card_accountId_fkey` ON `card`;

-- DropIndex
DROP INDEX `Card_clientId_fkey` ON `card`;

-- DropIndex
DROP INDEX `Contract_clientId_fkey` ON `contract`;

-- DropIndex
DROP INDEX `CustomField_clientId_fkey` ON `customfield`;

-- DropIndex
DROP INDEX `IdentityDocument_clientId_fkey` ON `identitydocument`;

-- DropIndex
DROP INDEX `InstallmentPlan_clientId_fkey` ON `installmentplan`;

-- DropIndex
DROP INDEX `LoyaltyBalance_cardId_fkey` ON `loyaltybalance`;

-- DropIndex
DROP INDEX `LoyaltyBalance_clientId_fkey` ON `loyaltybalance`;

-- DropIndex
DROP INDEX `LoyaltyOperation_balanceId_fkey` ON `loyaltyoperation`;

-- DropIndex
DROP INDEX `SmsRequest_cardId_fkey` ON `smsrequest`;

-- DropIndex
DROP INDEX `Transaction_accountId_fkey` ON `transaction`;

-- DropIndex
DROP INDEX `Transaction_cardId_fkey` ON `transaction`;

-- AlterTable
ALTER TABLE `account` DROP COLUMN `accountIdentifier`,
    ADD COLUMN `accountNumber` VARCHAR(191) NOT NULL DEFAULT 'MIGRATED_ACCOUNT',
    ADD COLUMN `branchCode` VARCHAR(191) NULL,
    ADD COLUMN `externalAccountId` VARCHAR(191) NULL,
    ADD COLUMN `productCode` VARCHAR(191) NULL,
    ADD COLUMN `profileCode` VARCHAR(191) NULL;

-- CreateTable
CREATE TABLE `ClientId` (
    `id` VARCHAR(191) NOT NULL,
    `value` VARCHAR(191) NULL,
    `type` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `clientId` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ClientIdQualifier` (
    `id` VARCHAR(191) NOT NULL,
    `value` VARCHAR(191) NULL,
    `type` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `clientIdId` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `CreditOptions` (
    `id` VARCHAR(191) NOT NULL,
    `creditLimitAmount` DECIMAL(18, 2) NULL,
    `billingDay` VARCHAR(191) NULL,
    `directDebitNumber` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `accountId` VARCHAR(191) NOT NULL,

    UNIQUE INDEX `CreditOptions_accountId_key`(`accountId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `DebitOptions` (
    `id` VARCHAR(191) NOT NULL,
    `accountType` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `accountId` VARCHAR(191) NOT NULL,

    UNIQUE INDEX `DebitOptions_accountId_key`(`accountId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateIndex
CREATE UNIQUE INDEX `Account_accountNumber_key` ON `Account`(`accountNumber`);

-- CreateIndex
CREATE UNIQUE INDEX `Account_externalAccountId_key` ON `Account`(`externalAccountId`);

-- AddForeignKey
ALTER TABLE `ClientId` ADD CONSTRAINT `ClientId_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ClientIdQualifier` ADD CONSTRAINT `ClientIdQualifier_clientIdId_fkey` FOREIGN KEY (`clientIdId`) REFERENCES `ClientId`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ContactDetails` ADD CONSTRAINT `ContactDetails_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PersonalDetails` ADD CONSTRAINT `PersonalDetails_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Address` ADD CONSTRAINT `Address_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `IdentityDocument` ADD CONSTRAINT `IdentityDocument_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `EmploymentDetails` ADD CONSTRAINT `EmploymentDetails_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `CustomField` ADD CONSTRAINT `CustomField_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Account` ADD CONSTRAINT `Account_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `CreditOptions` ADD CONSTRAINT `CreditOptions_accountId_fkey` FOREIGN KEY (`accountId`) REFERENCES `Account`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `DebitOptions` ADD CONSTRAINT `DebitOptions_accountId_fkey` FOREIGN KEY (`accountId`) REFERENCES `Account`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Card` ADD CONSTRAINT `Card_accountId_fkey` FOREIGN KEY (`accountId`) REFERENCES `Account`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Card` ADD CONSTRAINT `Card_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Transaction` ADD CONSTRAINT `Transaction_cardId_fkey` FOREIGN KEY (`cardId`) REFERENCES `Card`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Transaction` ADD CONSTRAINT `Transaction_accountId_fkey` FOREIGN KEY (`accountId`) REFERENCES `Account`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Contract` ADD CONSTRAINT `Contract_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `LoyaltyBalance` ADD CONSTRAINT `LoyaltyBalance_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `LoyaltyBalance` ADD CONSTRAINT `LoyaltyBalance_cardId_fkey` FOREIGN KEY (`cardId`) REFERENCES `Card`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `LoyaltyOperation` ADD CONSTRAINT `LoyaltyOperation_balanceId_fkey` FOREIGN KEY (`balanceId`) REFERENCES `LoyaltyBalance`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `InstallmentPlan` ADD CONSTRAINT `InstallmentPlan_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `SmsRequest` ADD CONSTRAINT `SmsRequest_cardId_fkey` FOREIGN KEY (`cardId`) REFERENCES `Card`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
