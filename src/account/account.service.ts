import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface CreateAccountPayload {
    // Flat structure (for direct calls)
    accountNumber?: string;
    externalAccountId?: string;
    productCode?: string;
    profileCode?: string;
    branchCode?: string;
    clientId?: string;
    creditOptions?: {
        creditLimitAmount?: number;
        billingDay?: string;
        directDebitNumber?: string;
    };
    debitOptions?: {
        accountType?: string;
    };

    // Nested structure (from Network International API)
    account?: {
        accountNumber?: string;
        externalAccountId?: string;
        productCode?: string;
        profileCode?: string;
        branchCode?: string;
    };
    client?: {
        id?: {
            value?: string;
            type?: string;
            additionalQualifiers?: Array<{
                value?: string;
                type?: string;
            }>;
        };
    };
    responseDetails?: boolean;
    customFields?: Array<{
        key?: string;
        value?: string;
    }>;
}

export interface UpdateAccountPayload {
    externalAccountId?: string;
    productCode?: string;
    profileCode?: string;
    branchCode?: string;
    creditOptions?: {
        creditLimitAmount?: number;
        billingDay?: string;
        directDebitNumber?: string;
    };
    debitOptions?: {
        accountType?: string;
    };
}

@Injectable()
export class AccountService {
    constructor(private prisma: PrismaService) { }

    async createAccount(payload: CreateAccountPayload) {
        console.log('AccountService.createAccount called with payload:', JSON.stringify(payload, null, 2));

        // Extract account details from either flat or nested structure
        const accountNumber = payload.accountNumber || payload.account?.accountNumber;
        const externalAccountId = payload.externalAccountId || payload.account?.externalAccountId;
        const productCode = payload.productCode || payload.account?.productCode;
        const profileCode = payload.profileCode || payload.account?.profileCode;
        const branchCode = payload.branchCode || payload.account?.branchCode;

        // Extract client ID from either direct field or nested structure
        const clientId = payload.clientId || payload.client?.id?.value;

        if (!accountNumber) {
            throw new Error('accountNumber is required for account creation');
        }

        if (!clientId) {
            throw new Error('clientId is required for account creation');
        }

        try {
            const result = await this.prisma.$transaction(async (tx) => {
                // Check if account already exists by accountNumber or externalAccountId
                let existingAccount: any = null;

                if (accountNumber) {
                    existingAccount = await tx.account.findUnique({
                        where: { accountNumber: accountNumber }
                    });
                }

                if (!existingAccount && externalAccountId) {
                    existingAccount = await tx.account.findUnique({
                        where: { externalAccountId: externalAccountId }
                    });
                }

                let account;
                if (existingAccount) {
                    // Update existing account
                    account = await tx.account.update({
                        where: { id: existingAccount.id },
                        data: {
                            accountNumber: accountNumber || existingAccount.accountNumber,
                            externalAccountId: externalAccountId || existingAccount.externalAccountId,
                            productCode: productCode,
                            profileCode: profileCode,
                            branchCode: branchCode,
                            clientId: clientId,
                        },
                    });
                } else {
                    // Create new account
                    account = await tx.account.create({
                        data: {
                            accountNumber: accountNumber,
                            externalAccountId: externalAccountId,
                            productCode: productCode,
                            profileCode: profileCode,
                            branchCode: branchCode,
                            clientId: clientId,
                        },
                    });
                }

                // Upsert CreditOptions if provided
                if (payload.creditOptions) {
                    await tx.creditOptions.upsert({
                        where: { accountId: account.id },
                        update: {
                            creditLimitAmount: payload.creditOptions.creditLimitAmount,
                            billingDay: payload.creditOptions.billingDay,
                            directDebitNumber: payload.creditOptions.directDebitNumber,
                        },
                        create: {
                            creditLimitAmount: payload.creditOptions.creditLimitAmount,
                            billingDay: payload.creditOptions.billingDay,
                            directDebitNumber: payload.creditOptions.directDebitNumber,
                            accountId: account.id,
                        },
                    });
                }

                // Upsert DebitOptions if provided
                if (payload.debitOptions) {
                    await tx.debitOptions.upsert({
                        where: { accountId: account.id },
                        update: {
                            accountType: payload.debitOptions.accountType,
                        },
                        create: {
                            accountType: payload.debitOptions.accountType,
                            accountId: account.id,
                        },
                    });
                }

                // Return account with related data
                return await tx.account.findUnique({
                    where: { id: account.id },
                    include: {
                        creditOptions: true,
                        debitOptions: true,
                        client: {
                            select: {
                                id: true,
                                clientId: true,
                                externalClientId: true,
                                firstName: true,
                                lastName: true,
                                email: true,
                            },
                        },
                    },
                });
            });

            return {
                success: true,
                account: result,
                message: 'Account created successfully',
            };

        } catch (error) {
            console.error('Error in createAccount:', error);
            throw error;
        }
    }

    async getAccount(accountId: string) {
        console.log('AccountService.getAccount called with accountId:', accountId);

        try {
            const account = await this.prisma.account.findUnique({
                where: { id: accountId },
                include: {
                    creditOptions: true,
                    debitOptions: true,
                    client: {
                        select: {
                            id: true,
                            clientId: true,
                            externalClientId: true,
                            firstName: true,
                            lastName: true,
                            email: true,
                        },
                    },
                    cards: true,
                },
            });

            if (!account) {
                throw new Error('Account not found');
            }

            return {
                success: true,
                account,
                message: 'Account retrieved successfully',
            };

        } catch (error) {
            console.error('Error in getAccount:', error);
            throw error;
        }
    }

    async getAccountsByClient(clientId: string) {
        console.log('AccountService.getAccountsByClient called with clientId:', clientId);

        try {
            const accounts = await this.prisma.account.findMany({
                where: { clientId },
                include: {
                    creditOptions: true,
                    debitOptions: true,
                    cards: true,
                },
            });

            return {
                success: true,
                accounts,
                count: accounts.length,
                message: 'Accounts retrieved successfully',
            };

        } catch (error) {
            console.error('Error in getAccountsByClient:', error);
            throw error;
        }
    }

    async updateAccount(accountId: string, payload: UpdateAccountPayload) {
        console.log('AccountService.updateAccount called with accountId:', accountId, 'payload:', JSON.stringify(payload, null, 2));

        try {
            const result = await this.prisma.$transaction(async (tx) => {
                // Update the account
                const account = await tx.account.update({
                    where: { id: accountId },
                    data: {
                        externalAccountId: payload.externalAccountId,
                        productCode: payload.productCode,
                        profileCode: payload.profileCode,
                        branchCode: payload.branchCode,
                    },
                });

                // Update CreditOptions if provided
                if (payload.creditOptions) {
                    await tx.creditOptions.upsert({
                        where: { accountId: account.id },
                        update: {
                            creditLimitAmount: payload.creditOptions.creditLimitAmount,
                            billingDay: payload.creditOptions.billingDay,
                            directDebitNumber: payload.creditOptions.directDebitNumber,
                        },
                        create: {
                            creditLimitAmount: payload.creditOptions.creditLimitAmount,
                            billingDay: payload.creditOptions.billingDay,
                            directDebitNumber: payload.creditOptions.directDebitNumber,
                            accountId: account.id,
                        },
                    });
                }

                // Update DebitOptions if provided
                if (payload.debitOptions) {
                    await tx.debitOptions.upsert({
                        where: { accountId: account.id },
                        update: {
                            accountType: payload.debitOptions.accountType,
                        },
                        create: {
                            accountType: payload.debitOptions.accountType,
                            accountId: account.id,
                        },
                    });
                }

                // Return updated account with related data
                return await tx.account.findUnique({
                    where: { id: account.id },
                    include: {
                        creditOptions: true,
                        debitOptions: true,
                        client: {
                            select: {
                                id: true,
                                clientId: true,
                                externalClientId: true,
                                firstName: true,
                                lastName: true,
                                email: true,
                            },
                        },
                    },
                });
            });

            return {
                success: true,
                account: result,
                message: 'Account updated successfully',
            };

        } catch (error) {
            console.error('Error in updateAccount:', error);
            throw error;
        }
    }

    async deleteAccount(accountId: string) {
        console.log('AccountService.deleteAccount called with accountId:', accountId);

        try {
            const result = await this.prisma.$transaction(async (tx) => {
                // Delete related records first
                await tx.creditOptions.deleteMany({
                    where: { accountId },
                });

                await tx.debitOptions.deleteMany({
                    where: { accountId },
                });

                // Delete the account
                const deletedAccount = await tx.account.delete({
                    where: { id: accountId },
                });

                return deletedAccount;
            });

            return {
                success: true,
                account: result,
                message: 'Account deleted successfully',
            };

        } catch (error) {
            console.error('Error in deleteAccount:', error);
            throw error;
        }
    }
}