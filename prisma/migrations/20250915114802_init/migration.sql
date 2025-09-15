-- CreateTable
CREATE TABLE `customers` (
    `customer_id` VARCHAR(20) NOT NULL,
    `bank_code` VARCHAR(5) NOT NULL,
    `external_client_number` VARCHAR(20) NULL,
    `card_name` VARCHAR(50) NULL,
    `card_type` ENUM('CREDIT', 'DEBIT', 'PREPAID') NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_bank_code`(`bank_code`),
    INDEX `idx_card_type`(`card_type`),
    INDEX `idx_external_client_number`(`external_client_number`),
    PRIMARY KEY (`customer_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `customer_personal_details` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `customer_id` VARCHAR(20) NOT NULL,
    `gender` ENUM('M', 'F', 'OTHER') NULL,
    `title` VARCHAR(4) NULL,
    `first_name` VARCHAR(255) NOT NULL,
    `last_name` VARCHAR(255) NOT NULL,
    `middle_name` VARCHAR(255) NULL,
    `citizenship` VARCHAR(3) NULL,
    `marital_status` VARCHAR(18) NULL,
    `date_of_birth` DATE NOT NULL,
    `place_of_birth` VARCHAR(255) NULL,
    `language` VARCHAR(3) NULL DEFAULT 'ENG',
    `security_name` VARCHAR(255) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_date_of_birth`(`date_of_birth`),
    UNIQUE INDEX `customer_personal_details_customer_id_key`(`customer_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `customer_contact_details` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `customer_id` VARCHAR(20) NOT NULL,
    `home_phone` VARCHAR(32) NULL,
    `work_phone` VARCHAR(32) NULL,
    `mobile_phone` VARCHAR(32) NULL,
    `email` VARCHAR(255) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_mobile_phone`(`mobile_phone`),
    INDEX `idx_email`(`email`),
    UNIQUE INDEX `customer_contact_details_customer_id_key`(`customer_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `customer_addresses` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `customer_id` VARCHAR(20) NOT NULL,
    `address_type` ENUM('PERMANENT', 'PRESENT', 'RESIDENT') NOT NULL,
    `address_line_1` VARCHAR(255) NOT NULL,
    `address_line_2` VARCHAR(255) NULL,
    `address_line_3` VARCHAR(255) NULL,
    `address_line_4` VARCHAR(255) NULL,
    `city` VARCHAR(255) NOT NULL,
    `state` VARCHAR(128) NULL,
    `country` VARCHAR(255) NOT NULL,
    `zip` VARCHAR(32) NULL,
    `phone` VARCHAR(32) NULL,
    `email` VARCHAR(255) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_customer_id`(`customer_id`),
    INDEX `idx_address_type`(`address_type`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `identity_documents` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `customer_id` VARCHAR(20) NOT NULL,
    `document_type` ENUM('IDENTITY_PROOF', 'SUPPLEMENTARY') NOT NULL,
    `document_subtype` VARCHAR(20) NULL,
    `document_number` VARCHAR(20) NULL,
    `expiry_date` DATE NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_customer_id`(`customer_id`),
    INDEX `idx_document_type`(`document_type`),
    INDEX `idx_document_number`(`document_number`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `employment_details` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `customer_id` VARCHAR(20) NOT NULL,
    `employer_name` VARCHAR(64) NULL,
    `income` DECIMAL(15, 2) NULL,
    `occupation` VARCHAR(64) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_customer_id`(`customer_id`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `accounts` (
    `account_number` VARCHAR(64) NOT NULL,
    `customer_id` VARCHAR(20) NOT NULL,
    `branch_code` VARCHAR(10) NOT NULL,
    `product_code` VARCHAR(32) NOT NULL,
    `currency` VARCHAR(3) NOT NULL,
    `account_type` VARCHAR(15) NULL,
    `account_role` ENUM('PRIMARY', 'SUPPLEMENTARY') NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_customer_id`(`customer_id`),
    INDEX `idx_branch_code`(`branch_code`),
    INDEX `idx_currency`(`currency`),
    INDEX `idx_product_code`(`product_code`),
    PRIMARY KEY (`account_number`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `cards` (
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `card_identifier_type` ENUM('CONTRACT_NUMBER', 'EXID') NOT NULL,
    `customer_id` VARCHAR(20) NOT NULL,
    `account_number` VARCHAR(64) NULL,
    `institution_id` VARCHAR(5) NULL,
    `cardholder_name` VARCHAR(50) NOT NULL,
    `product_code` VARCHAR(32) NOT NULL,
    `card_role` ENUM('P', 'S') NOT NULL,
    `currency` VARCHAR(3) NOT NULL,
    `card_virtual_indicator` ENUM('P', 'V') NOT NULL,
    `card_expiry_date` VARCHAR(4) NULL,
    `card_sequence_number` VARCHAR(2) NULL,
    `masked_pan` VARCHAR(20) NULL,
    `card_date_open` DATE NULL,
    `card_activation_date` DATE NULL,
    `last_statement_date` DATE NULL,
    `next_statement_date` DATE NULL,
    `due_date` DATE NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_customer_id`(`customer_id`),
    INDEX `idx_account_number`(`account_number`),
    INDEX `idx_card_expiry`(`card_expiry_date`),
    INDEX `idx_card_role`(`card_role`),
    INDEX `idx_product_code`(`product_code`),
    INDEX `idx_masked_pan`(`masked_pan`),
    PRIMARY KEY (`card_identifier_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_statuses` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `status_type` VARCHAR(32) NOT NULL,
    `status_value` VARCHAR(32) NOT NULL,
    `changed_date` DATE NOT NULL,
    `description` VARCHAR(100) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_status_type`(`status_type`),
    INDEX `idx_changed_date`(`changed_date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_limits` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `limit_type` VARCHAR(32) NOT NULL,
    `scope_code` VARCHAR(1) NULL,
    `currency` VARCHAR(3) NOT NULL,
    `max_number` INTEGER NULL,
    `max_single_amount` DECIMAL(15, 2) NULL,
    `max_amount` DECIMAL(15, 2) NULL,
    `start_date` DATE NULL,
    `end_date` DATE NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_limit_type`(`limit_type`),
    INDEX `idx_currency`(`currency`),
    INDEX `idx_scope_code`(`scope_code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_balances` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `balance_type` VARCHAR(32) NOT NULL,
    `currency` VARCHAR(3) NOT NULL,
    `amount` DECIMAL(15, 2) NOT NULL,
    `as_of_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_balance_type`(`balance_type`),
    INDEX `idx_as_of_date`(`as_of_date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_restrictions` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `restriction_type` VARCHAR(10) NOT NULL,
    `scope_code` VARCHAR(1) NULL,
    `is_allowed` BOOLEAN NOT NULL,
    `start_date` DATE NULL,
    `end_date` DATE NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_restriction_type`(`restriction_type`),
    INDEX `idx_scope_code`(`scope_code`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `transactions` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `transaction_code` VARCHAR(12) NOT NULL,
    `transaction_ref_number` VARCHAR(12) NOT NULL,
    `amount` DECIMAL(15, 2) NOT NULL,
    `currency` VARCHAR(3) NOT NULL,
    `description` VARCHAR(255) NULL,
    `counter_party_number` VARCHAR(20) NULL,
    `transaction_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `transaction_type` ENUM('authorized', 'posted', 'statemented', 'time_based') NULL,
    `status` ENUM('S', 'F') NOT NULL DEFAULT 'S',
    `response_code` VARCHAR(10) NULL,
    `mcc_group` VARCHAR(50) NULL,
    `wallet_id` VARCHAR(20) NULL,

    UNIQUE INDEX `transactions_transaction_ref_number_key`(`transaction_ref_number`),
    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_transaction_date`(`transaction_date`),
    INDEX `idx_transaction_code`(`transaction_code`),
    INDEX `idx_ref_number`(`transaction_ref_number`),
    INDEX `idx_transaction_type`(`transaction_type`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `installment_plans` (
    `plan_number` VARCHAR(5) NOT NULL,
    `plan_name` VARCHAR(100) NULL,
    `number_of_portions` INTEGER NOT NULL,
    `interest_rate` DECIMAL(5, 2) NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `idx_is_active`(`is_active`),
    PRIMARY KEY (`plan_number`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_installments` (
    `instalment_id` VARCHAR(20) NOT NULL,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `plan_number` VARCHAR(5) NOT NULL,
    `creation_date` DATE NOT NULL,
    `first_payment_date` DATE NULL,
    `close_date` DATE NULL,
    `currency` VARCHAR(3) NOT NULL,
    `total_amount` DECIMAL(15, 2) NOT NULL,
    `principal` DECIMAL(15, 2) NOT NULL,
    `fee` DECIMAL(15, 2) NULL,
    `paid_amount` DECIMAL(15, 2) NOT NULL DEFAULT 0,
    `due_amount` DECIMAL(15, 2) NULL,
    `overdue_amount` DECIMAL(15, 2) NOT NULL DEFAULT 0,
    `written_off_amount` DECIMAL(15, 2) NOT NULL DEFAULT 0,
    `portion_total` DECIMAL(15, 2) NULL,
    `portion_principal` DECIMAL(15, 2) NULL,
    `portion_fee` DECIMAL(15, 2) NULL,

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_plan_number`(`plan_number`),
    INDEX `idx_creation_date`(`creation_date`),
    INDEX `idx_close_date`(`close_date`),
    PRIMARY KEY (`instalment_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_statements` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `statement_period` VARCHAR(4) NOT NULL,
    `statement_date` DATE NOT NULL,
    `last_statement_date` DATE NULL,
    `statement_opening_balance` DECIMAL(15, 2) NULL,
    `statement_closing_balance` DECIMAL(15, 2) NULL,
    `due_amount` DECIMAL(15, 2) NULL,
    `due_date` DATE NULL,
    `full_payment_amount` DECIMAL(15, 2) NULL,
    `interest_this_statement` DECIMAL(15, 2) NULL,
    `statement_available_balance` DECIMAL(15, 2) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_statement_period`(`statement_period`),
    INDEX `idx_statement_date`(`statement_date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `reward_programs` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `statement_id` BIGINT NOT NULL,
    `reward_type` VARCHAR(20) NULL,
    `reward_open_balance` DECIMAL(15, 2) NULL,
    `reward_balance` DECIMAL(15, 2) NULL,
    `reward_earned` DECIMAL(15, 2) NULL,
    `reward_redeemed` DECIMAL(15, 2) NULL,
    `reward_adjust` DECIMAL(15, 2) NULL,
    `reward_total_earned` DECIMAL(15, 2) NULL,

    INDEX `idx_statement_id`(`statement_id`),
    INDEX `idx_reward_type`(`reward_type`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_pin_operations` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `operation_type` VARCHAR(20) NOT NULL,
    `encrypted_pin` VARCHAR(20) NULL,
    `encrypted_old_pin` VARCHAR(20) NULL,
    `encryption_method` ENUM('SYMMETRIC', 'SYMMETRIC_ENC', 'ASYNC_ENC') NULL,
    `encryption_key_id` VARCHAR(20) NULL,
    `encryption_key_type` VARCHAR(20) NULL,
    `operation_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `status` ENUM('S', 'F') NOT NULL DEFAULT 'S',
    `response_code` VARCHAR(10) NULL,

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_operation_type`(`operation_type`),
    INDEX `idx_operation_date`(`operation_date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `card_replacements` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `old_card_identifier_id` VARCHAR(32) NOT NULL,
    `new_card_identifier_id` VARCHAR(32) NULL,
    `new_card_identifier_type` VARCHAR(20) NULL,
    `new_card_expiry_date` VARCHAR(4) NULL,
    `new_masked_pan` VARCHAR(20) NULL,
    `action_type` VARCHAR(20) NOT NULL,
    `reason` VARCHAR(255) NULL,
    `request_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `completion_date` DATETIME(3) NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    INDEX `idx_old_card_id`(`old_card_identifier_id`),
    INDEX `idx_new_card_id`(`new_card_identifier_id`),
    INDEX `idx_request_date`(`request_date`),
    INDEX `idx_status`(`status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `balance_transfers` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `plan_number` VARCHAR(5) NOT NULL,
    `currency` VARCHAR(3) NOT NULL,
    `amount` DECIMAL(15, 2) NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `transaction_ref_number` VARCHAR(12) NOT NULL,
    `transfer_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `status` ENUM('S', 'F') NOT NULL DEFAULT 'S',
    `override_options` JSON NULL,

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_plan_number`(`plan_number`),
    INDEX `idx_transfer_date`(`transfer_date`),
    INDEX `idx_transaction_ref_number`(`transaction_ref_number`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `loans_on_call` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `plan_number` VARCHAR(5) NOT NULL,
    `currency` VARCHAR(3) NOT NULL,
    `amount` DECIMAL(15, 2) NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `transaction_ref_number` VARCHAR(12) NOT NULL,
    `loan_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `status` ENUM('S', 'F') NOT NULL DEFAULT 'S',
    `override_options` JSON NULL,

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_plan_number`(`plan_number`),
    INDEX `idx_loan_date`(`loan_date`),
    INDEX `idx_transaction_ref_number`(`transaction_ref_number`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `transaction_refinances` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `trans_id` VARCHAR(32) NOT NULL,
    `plan_number` VARCHAR(5) NOT NULL,
    `instalment_description` VARCHAR(255) NOT NULL,
    `channel` VARCHAR(20) NOT NULL,
    `currency` VARCHAR(3) NULL,
    `amount` DECIMAL(15, 2) NULL,
    `rrn` VARCHAR(20) NULL,
    `auth_code` VARCHAR(20) NULL,
    `refinance_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `status` ENUM('S', 'F') NOT NULL DEFAULT 'S',
    `override_options` JSON NULL,

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_transaction_id`(`trans_id`),
    INDEX `idx_plan_number`(`plan_number`),
    INDEX `idx_refinance_date`(`refinance_date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `cvv2_requests` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `expiry_date` VARCHAR(4) NOT NULL,
    `cvv2` VARCHAR(4) NULL,
    `request_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `status` ENUM('S', 'F') NOT NULL DEFAULT 'S',

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_request_date`(`request_date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `custom_fields` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `entity_type` ENUM('CUSTOMER', 'CARD', 'ACCOUNT', 'TRANSACTION') NOT NULL,
    `entity_id` VARCHAR(64) NOT NULL,
    `field_key` VARCHAR(32) NOT NULL,
    `field_value` VARCHAR(128) NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,

    INDEX `idx_entity`(`entity_type`, `entity_id`),
    INDEX `idx_field_key`(`field_key`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `api_audit_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `msg_id` VARCHAR(12) NOT NULL,
    `msg_type` ENUM('TRANSACTION', 'ENQUIRY') NOT NULL,
    `msg_function` VARCHAR(50) NOT NULL,
    `src_application` VARCHAR(10) NULL,
    `target_application` VARCHAR(10) NULL,
    `bank_id` VARCHAR(4) NULL,
    `request_timestamp` DATETIME(3) NULL,
    `response_timestamp` DATETIME(3) NULL,
    `status` ENUM('S', 'F') NULL,
    `error_code` VARCHAR(4) NULL,
    `error_description` VARCHAR(100) NULL,
    `tracking_id` VARCHAR(30) NULL,
    `instance_id` VARCHAR(10) NULL,

    INDEX `idx_msg_id`(`msg_id`),
    INDEX `idx_msg_function`(`msg_function`),
    INDEX `idx_request_timestamp`(`request_timestamp`),
    INDEX `idx_status`(`status`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `eligible_plans` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `plan_number` VARCHAR(5) NOT NULL,
    `number_of_portions` INTEGER NOT NULL,
    `interest` DECIMAL(5, 2) NOT NULL,
    `action` VARCHAR(20) NULL,
    `trans_id` VARCHAR(20) NULL,
    `balance_amount` DECIMAL(15, 2) NULL,
    `check_date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_plan_number`(`plan_number`),
    INDEX `idx_check_date`(`check_date`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `linked_accounts` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `account_number` VARCHAR(60) NOT NULL,
    `account_type` VARCHAR(15) NULL,
    `account_role` ENUM('PRIMARY', 'SUPPLEMENTARY') NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_account_number`(`account_number`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `limit_usage` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `card_identifier_id` VARCHAR(32) NOT NULL,
    `limit_type` VARCHAR(32) NOT NULL,
    `scope_code` VARCHAR(1) NULL,
    `currency` VARCHAR(3) NOT NULL,
    `used_amount` DECIMAL(15, 2) NULL,
    `used_count` INTEGER NULL,
    `period_start` DATETIME(3) NOT NULL,
    `period_end` DATETIME(3) NOT NULL,
    `channel_type` VARCHAR(10) NULL,
    `last_updated` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `idx_card_id`(`card_identifier_id`),
    INDEX `idx_limit_type`(`limit_type`),
    INDEX `idx_period_start`(`period_start`),
    INDEX `idx_period_end`(`period_end`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `customer_personal_details` ADD CONSTRAINT `customer_personal_details_customer_id_fkey` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `customer_contact_details` ADD CONSTRAINT `customer_contact_details_customer_id_fkey` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `customer_addresses` ADD CONSTRAINT `customer_addresses_customer_id_fkey` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `identity_documents` ADD CONSTRAINT `identity_documents_customer_id_fkey` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `employment_details` ADD CONSTRAINT `employment_details_customer_id_fkey` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `accounts` ADD CONSTRAINT `accounts_customer_id_fkey` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `cards` ADD CONSTRAINT `cards_customer_id_fkey` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `cards` ADD CONSTRAINT `cards_account_number_fkey` FOREIGN KEY (`account_number`) REFERENCES `accounts`(`account_number`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_statuses` ADD CONSTRAINT `card_statuses_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_limits` ADD CONSTRAINT `card_limits_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_balances` ADD CONSTRAINT `card_balances_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_restrictions` ADD CONSTRAINT `card_restrictions_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `transactions` ADD CONSTRAINT `transactions_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_installments` ADD CONSTRAINT `card_installments_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_installments` ADD CONSTRAINT `card_installments_plan_number_fkey` FOREIGN KEY (`plan_number`) REFERENCES `installment_plans`(`plan_number`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_statements` ADD CONSTRAINT `card_statements_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `reward_programs` ADD CONSTRAINT `reward_programs_statement_id_fkey` FOREIGN KEY (`statement_id`) REFERENCES `card_statements`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_pin_operations` ADD CONSTRAINT `card_pin_operations_card_identifier_id_fkey` FOREIGN KEY (`card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `card_replacements` ADD CONSTRAINT `card_replacements_old_card_identifier_id_fkey` FOREIGN KEY (`old_card_identifier_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `custom_fields` ADD CONSTRAINT `custom_fields_customer_fkey` FOREIGN KEY (`entity_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `custom_fields` ADD CONSTRAINT `custom_fields_account_fkey` FOREIGN KEY (`entity_id`) REFERENCES `accounts`(`account_number`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `custom_fields` ADD CONSTRAINT `custom_fields_card_fkey` FOREIGN KEY (`entity_id`) REFERENCES `cards`(`card_identifier_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `custom_fields` ADD CONSTRAINT `custom_fields_transaction_fkey` FOREIGN KEY (`entity_id`) REFERENCES `transactions`(`transaction_ref_number`) ON DELETE CASCADE ON UPDATE CASCADE;
