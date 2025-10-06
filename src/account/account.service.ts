import { Injectable, NotFoundException, BadRequestException, InternalServerErrorException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { resolveClientIdFromPayload } from '../prisma/client-resolver';
import type { RequestHeaders } from '../common/header-utils';

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

    async createAccount(payload: CreateAccountPayload, headers: RequestHeaders) {
        console.log('AccountService.createAccount called with payload:', JSON.stringify(payload, null, 2));

        // Extract account details from either flat or nested structure
        const accountNumber = payload.accountNumber || payload.account?.accountNumber;
        const externalAccountId = payload.externalAccountId || payload.account?.externalAccountId;
        const productCode = payload.productCode || payload.account?.productCode;
        const profileCode = payload.profileCode || payload.account?.profileCode;
        const branchCode = payload.branchCode || payload.account?.branchCode;

        // Extract and resolve client ID from various sources
        let clientId = payload.clientId;
        if (!clientId) {
            // use centralized resolver which tries clientId, externalClientNumber, UUID fallback, etc.
            clientId = await resolveClientIdFromPayload(payload, this.prisma);
            if (!clientId && payload.client?.id) {
                const clientIdType = payload.client.id.type;
                const clientIdValue = payload.client.id.value;
                throw new NotFoundException(`No client found for ${clientIdType}: ${clientIdValue}`);
            }
        }

        if (!accountNumber) {
            throw new BadRequestException('accountNumber is required for account creation');
        }

        if (!clientId) {
            throw new BadRequestException('clientId is required for account creation');
        }

        try {
            let wasCreated = false;
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
                    // If existing account belongs to a different client, don't silently reassign
                    if (existingAccount.clientId && existingAccount.clientId !== clientId) {
                        throw new ConflictException(`Account with accountNumber/externalAccountId already exists for another client`);
                    }

                    // If account already exists for the same client, do not recreate it.
                    // We'll return the existing record and avoid reassigning ownership.
                    if (existingAccount.clientId && existingAccount.clientId === clientId) {
                        account = existingAccount;
                        wasCreated = false;
                    } else {
                        // existingAccount exists but has no clientId set - attach to this client
                        account = await tx.account.update({
                            where: { id: existingAccount.id },
                            data: {
                                accountNumber: accountNumber || existingAccount.accountNumber,
                                externalAccountId: externalAccountId || existingAccount.externalAccountId,
                                productCode: productCode,
                                profileCode: profileCode,
                                branchCode: branchCode,
                                clientId: existingAccount.clientId || clientId,
                            },
                        });
                        wasCreated = false;
                    }
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
                    wasCreated = true;
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
                const fullAccount = await tx.account.findUnique({
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

                // Store request audit for traceability
                try {
                    await tx.requestAudit.create({
                        data: {
                            requestIdHeader: headers.requestId,
                            correlationId: headers.correlationId,
                            orgId: headers.orgId,
                            srcApp: headers.srcApp,
                            channel: headers.channel,
                            timestampHeader: headers.timestamp,
                            rawHeaders: headers as any,
                            rawBody: {
                                payload,
                                account: {
                                    id: fullAccount?.id,
                                    accountNumber: fullAccount?.accountNumber,
                                    externalAccountId: fullAccount?.externalAccountId,
                                }
                            } as any
                        }
                    });
                } catch (auditErr) {
                    // non-fatal: log and continue returning the account
                    console.warn('Failed to write RequestAudit for account create:', auditErr?.message || auditErr);
                }

                return fullAccount;
            });

            // Debugging: log what happened for visibility
            console.log('createAccount debug:', {
                resolvedClientId: clientId,
                resultAccountId: result?.id,
                resultClientId: result?.clientId,
                wasCreated,
            });

            return {
                success: true,
                account: result,
                message: result && result.clientId === clientId && !wasCreated ? 'Account already exists' : 'Account created successfully',
                wasCreated: wasCreated
            };

        } catch (error) {
            console.error('Error in createAccount:', error);
            // Write a RequestAudit entry for failed attempts (non-fatal)
            try {
                await this.prisma.requestAudit.create({
                    data: {
                        requestIdHeader: headers.requestId,
                        correlationId: headers.correlationId,
                        orgId: headers.orgId,
                        srcApp: headers.srcApp,
                        channel: headers.channel,
                        timestampHeader: headers.timestamp,
                        rawHeaders: headers as any,
                        rawBody: {
                            payload,
                            error: {
                                message: error?.message,
                                name: error?.name,
                                code: error?.code || null
                            }
                        } as any
                    }
                });
            } catch (auditErr) {
                console.warn('Failed to write RequestAudit for failed account create:', auditErr?.message || auditErr);
            }

            // Allow known HttpExceptions to propagate to the controller unchanged
            if (
                error instanceof NotFoundException ||
                error instanceof BadRequestException ||
                error instanceof ConflictException
            ) throw error;
            throw new InternalServerErrorException(error?.message || 'Failed to create account');
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
                throw new NotFoundException('Account not found');
            }

            return {
                success: true,
                account,
                message: 'Account retrieved successfully',
            };

        } catch (error) {
            console.error('Error in getAccount:', error);
            if (error instanceof NotFoundException) throw error;
            throw new InternalServerErrorException(error?.message || 'Failed to get account');
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
            throw new InternalServerErrorException(error?.message || 'Failed to get accounts');
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
            if (error instanceof NotFoundException || error instanceof BadRequestException) throw error;
            throw new InternalServerErrorException(error?.message || 'Failed to update account');
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
            if (error instanceof NotFoundException) throw error;
            throw new InternalServerErrorException(error?.message || 'Failed to delete account');
        }
    }
}