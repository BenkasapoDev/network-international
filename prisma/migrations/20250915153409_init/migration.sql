/*
  Warnings:

  - You are about to drop the `accounts` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `api_audit_log` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `balance_transfers` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_balances` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_installments` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_limits` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_pin_operations` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_replacements` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_restrictions` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_statements` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `card_statuses` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `cards` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `custom_fields` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `customer_addresses` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `customer_contact_details` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `customer_personal_details` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `customers` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `cvv2_requests` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `eligible_plans` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `employment_details` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `identity_documents` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `installment_plans` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `limit_usage` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `linked_accounts` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `loans_on_call` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `reward_programs` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `transaction_refinances` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `transactions` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
DROP TABLE `accounts`;

-- DropTable
DROP TABLE `api_audit_log`;

-- DropTable
DROP TABLE `balance_transfers`;

-- DropTable
DROP TABLE `card_balances`;

-- DropTable
DROP TABLE `card_installments`;

-- DropTable
DROP TABLE `card_limits`;

-- DropTable
DROP TABLE `card_pin_operations`;

-- DropTable
DROP TABLE `card_replacements`;

-- DropTable
DROP TABLE `card_restrictions`;

-- DropTable
DROP TABLE `card_statements`;

-- DropTable
DROP TABLE `card_statuses`;

-- DropTable
DROP TABLE `cards`;

-- DropTable
DROP TABLE `custom_fields`;

-- DropTable
DROP TABLE `customer_addresses`;

-- DropTable
DROP TABLE `customer_contact_details`;

-- DropTable
DROP TABLE `customer_personal_details`;

-- DropTable
DROP TABLE `customers`;

-- DropTable
DROP TABLE `cvv2_requests`;

-- DropTable
DROP TABLE `eligible_plans`;

-- DropTable
DROP TABLE `employment_details`;

-- DropTable
DROP TABLE `identity_documents`;

-- DropTable
DROP TABLE `installment_plans`;

-- DropTable
DROP TABLE `limit_usage`;

-- DropTable
DROP TABLE `linked_accounts`;

-- DropTable
DROP TABLE `loans_on_call`;

-- DropTable
DROP TABLE `reward_programs`;

-- DropTable
DROP TABLE `transaction_refinances`;

-- DropTable
DROP TABLE `transactions`;

-- CreateTable
CREATE TABLE `Client` (
    `id` VARCHAR(191) NOT NULL,
    `externalId` VARCHAR(191) NULL,
    `firstName` VARCHAR(191) NULL,
    `lastName` VARCHAR(191) NULL,
    `legalName` VARCHAR(191) NULL,
    `email` VARCHAR(191) NULL,
    `phone` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    UNIQUE INDEX `Client_externalId_key`(`externalId`),
    UNIQUE INDEX `Client_email_key`(`email`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Account` (
    `id` VARCHAR(191) NOT NULL,
    `accountIdentifier` VARCHAR(191) NOT NULL,
    `currency` CHAR(3) NULL,
    `status` VARCHAR(191) NULL,
    `openedAt` DATETIME(3) NULL,
    `metadata` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `clientId` VARCHAR(191) NULL,

    UNIQUE INDEX `Account_accountIdentifier_key`(`accountIdentifier`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Card` (
    `id` VARCHAR(191) NOT NULL,
    `cardGuid` VARCHAR(191) NULL,
    `externalCardId` VARCHAR(191) NULL,
    `maskedCardNumber` VARCHAR(191) NULL,
    `productCode` VARCHAR(191) NULL,
    `productBin` VARCHAR(191) NULL,
    `productName` VARCHAR(191) NULL,
    `cardRole` VARCHAR(191) NULL,
    `isVirtual` BOOLEAN NOT NULL DEFAULT false,
    `cardExpiryDate` VARCHAR(191) NULL,
    `cardDateOpen` DATETIME(3) NULL,
    `cardActivationDate` DATETIME(3) NULL,
    `status` VARCHAR(191) NULL,
    `customFields` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `accountId` VARCHAR(191) NULL,
    `clientId` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Transaction` (
    `id` VARCHAR(191) NOT NULL,
    `maskedPan` VARCHAR(191) NULL,
    `cardIdentifierType` VARCHAR(191) NULL,
    `postDate` DATETIME(3) NULL,
    `transactionDate` DATETIME(3) NULL,
    `debitCreditFlag` BOOLEAN NULL,
    `responseCode` VARCHAR(191) NULL,
    `description` VARCHAR(191) NULL,
    `transactionRefNumber` VARCHAR(191) NULL,
    `transactionId` VARCHAR(191) NULL,
    `transactionCode` VARCHAR(191) NULL,
    `transactionType` VARCHAR(191) NULL,
    `currency` CHAR(3) NULL,
    `amount` DECIMAL(18, 4) NULL,
    `sourceCurrency` CHAR(3) NULL,
    `sourceAmount` DECIMAL(18, 4) NULL,
    `authCode` VARCHAR(191) NULL,
    `merchantId` VARCHAR(191) NULL,
    `merchantCategoryGroup` VARCHAR(191) NULL,
    `merchantCategoryCode` VARCHAR(191) NULL,
    `merchantName` VARCHAR(191) NULL,
    `merchantCity` VARCHAR(191) NULL,
    `merchantCountry` VARCHAR(191) NULL,
    `rawPayload` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `cardId` VARCHAR(191) NULL,
    `accountId` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Contract` (
    `id` VARCHAR(191) NOT NULL,
    `contractNumber` VARCHAR(191) NOT NULL,
    `profileCode` VARCHAR(191) NULL,
    `branchCode` VARCHAR(191) NULL,
    `statusValue` VARCHAR(191) NULL,
    `metadata` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `clientId` VARCHAR(191) NULL,

    UNIQUE INDEX `Contract_contractNumber_key`(`contractNumber`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `LoyaltyBalance` (
    `id` VARCHAR(191) NOT NULL,
    `balance` DECIMAL(18, 4) NULL,
    `currency` CHAR(3) NULL,
    `updatedAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `clientId` VARCHAR(191) NULL,
    `cardId` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `LoyaltyOperation` (
    `id` VARCHAR(191) NOT NULL,
    `operationType` VARCHAR(191) NULL,
    `amount` DECIMAL(18, 4) NULL,
    `amountType` VARCHAR(191) NULL,
    `source` VARCHAR(191) NULL,
    `rawPayload` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `balanceId` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `InstallmentPlan` (
    `id` VARCHAR(191) NOT NULL,
    `installmentPlanId` VARCHAR(191) NOT NULL,
    `totalAmount` DECIMAL(18, 4) NULL,
    `months` INTEGER NULL,
    `sourceAccount` VARCHAR(191) NULL,
    `destinationAccount` VARCHAR(191) NULL,
    `status` VARCHAR(191) NULL,
    `metadata` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `clientId` VARCHAR(191) NULL,

    UNIQUE INDEX `InstallmentPlan_installmentPlanId_key`(`installmentPlanId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `SmsRequest` (
    `id` VARCHAR(191) NOT NULL,
    `mobileNumber` VARCHAR(191) NULL,
    `requestType` VARCHAR(191) NULL,
    `status` VARCHAR(191) NULL,
    `trackingId` VARCHAR(191) NULL,
    `requestPayload` JSON NULL,
    `responsePayload` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `cardId` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Lookup` (
    `id` VARCHAR(191) NOT NULL,
    `category` VARCHAR(191) NULL,
    `key` VARCHAR(191) NULL,
    `value` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `RequestAudit` (
    `id` VARCHAR(191) NOT NULL,
    `requestIdHeader` VARCHAR(191) NULL,
    `correlationId` VARCHAR(191) NULL,
    `orgId` VARCHAR(191) NULL,
    `srcApp` VARCHAR(191) NULL,
    `channel` VARCHAR(191) NULL,
    `timestampHeader` DATETIME(3) NULL,
    `rawHeaders` JSON NULL,
    `rawBody` JSON NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `Account` ADD CONSTRAINT `Account_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Client`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

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
