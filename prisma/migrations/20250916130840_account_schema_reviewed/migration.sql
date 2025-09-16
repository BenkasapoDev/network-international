-- DropIndex
DROP INDEX `Account_clientId_fkey` ON `account`;

-- DropIndex
DROP INDEX `Address_clientId_fkey` ON `address`;

-- DropIndex
DROP INDEX `Card_accountId_fkey` ON `card`;

-- DropIndex
DROP INDEX `Card_clientId_fkey` ON `card`;

-- DropIndex
DROP INDEX `ClientId_clientId_fkey` ON `clientid`;

-- DropIndex
DROP INDEX `ClientIdQualifier_clientIdId_fkey` ON `clientidqualifier`;

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
ALTER TABLE `account` ALTER COLUMN `accountNumber` DROP DEFAULT;

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
