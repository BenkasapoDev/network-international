import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { resolveClientIdFromPayload } from '../prisma/client-resolver';
import type { RequestHeaders } from '../common/header-utils';

export interface CreateCardPayload {
    externalCardId?: string;
    cardNumber?: string;
    productCode?: string;
    productName?: string;
    cardRole?: string;
    isVirtual?: boolean;
    cardExpiryDate?: string;
    status?: string;
    customFields?: any;

    // Nested format
    card?: {
        externalCardId?: string;
        cardNumber?: string;
        productCode?: string;
        productName?: string;
        cardRole?: string;
        isVirtual?: boolean;
        cardExpiryDate?: string;
        status?: string;
        customFields?: any;
        accountNumber?: string; // to resolve account
        cardDateOpen?: string;
    };

    account?: {
        id?: {
            value?: string;
            type?: string;
            additionalQualifiers?: Array<{ value?: string; type?: string }>;
        };
    };

    client?: {
        id?: {
            value?: string;
            type?: string;
            additionalQualifiers?: Array<{ value?: string; type?: string }>;
        };
    };

    embossingDetails?: {
        title?: string;
        firstName?: string;
        lastName?: string;
    };

    responseDetails?: boolean;
}

@Injectable()
export class CardService {
    constructor(private prisma: PrismaService) { }

    private async resolveClientIdFromPayload(payload: CreateCardPayload, tx?: any) {
        const prismaTx = tx || this.prisma;
        let clientId = null as string | null;

        // direct
        if ((payload as any).clientId) {
            clientId = (payload as any).clientId;
        }

        // Resolve client id using centralized resolver which also supports UUID fallback
        if (!clientId) {
            clientId = await resolveClientIdFromPayload(payload, this.prisma);
            if (!clientId && payload.client?.id) {
                const clientIdType = payload.client.id.type;
                const clientIdValue = payload.client.id.value;
                throw new NotFoundException(`No client found for ${clientIdType}: ${clientIdValue}`);
            }
        }

        return clientId;
    }

    private async resolveAccountIdFromPayload(payload: CreateCardPayload, clientId: string | null, tx?: any) {
        const prismaTx = tx || this.prisma;
        let accountId: string | null = null;

        // Try different account identification methods
        let accountIdentifier: string | null = null;
        let accountIdentifierType: 'accountNumber' | 'externalAccountId' | 'accountId' | null = null;

        // 1. Check for account.id.value (new pattern)
        if (payload.account?.id?.value) {
            accountIdentifier = payload.account.id.value;
            // Determine type based on account.id.type or infer from value
            if (payload.account.id.type === 'accountNumber') {
                accountIdentifierType = 'accountNumber';
            } else if (payload.account.id.type === 'externalAccountId') {
                accountIdentifierType = 'externalAccountId';
            } else if (payload.account.id.type === 'accountId') {
                accountIdentifierType = 'accountId';
            } else {
                // Default to accountNumber for backwards compatibility
                accountIdentifierType = 'accountNumber';
            }
        }
        // 2. Check for legacy accountNumber patterns
        else {
            const acctNumber = (payload as any).accountNumber || payload.card?.accountNumber;
            if (acctNumber) {
                accountIdentifier = acctNumber;
                accountIdentifierType = 'accountNumber';
            }
        }

        // Resolve account if we have an identifier
        if (accountIdentifier && accountIdentifierType) {
            let whereClause: any;
            switch (accountIdentifierType) {
                case 'accountNumber':
                    whereClause = { accountNumber: accountIdentifier };
                    break;
                case 'externalAccountId':
                    whereClause = { externalAccountId: accountIdentifier };
                    break;
                case 'accountId':
                    whereClause = { id: accountIdentifier };
                    break;
            }

            const account = await prismaTx.account.findUnique({
                where: whereClause,
                include: { client: true }
            });

            if (account) {
                // Validate that the account belongs to the same client
                if (clientId && account.clientId !== clientId) {
                    throw new Error(`Account ${accountIdentifier} does not belong to client ${clientId}`);
                }
                accountId = account.id;
            } else {
                console.warn(`Account not found with ${accountIdentifierType}: ${accountIdentifier}`);
            }
        }

        return accountId;
    }

    async createCard(payload: CreateCardPayload, headers: RequestHeaders) {
        console.log('CardService.createCard called with payload:', JSON.stringify(payload, null, 2));

        // Extract fields
        const externalCardId = payload.externalCardId || payload.card?.externalCardId;
        const cardNumber = payload.cardNumber || payload.card?.cardNumber;
        const productCode = payload.productCode || payload.card?.productCode;
        const productName = payload.productName || payload.card?.productName;
        const cardRole = payload.cardRole || payload.card?.cardRole;
        const isVirtual = payload.isVirtual ?? payload.card?.isVirtual ?? false;
        const cardExpiryDate = payload.cardExpiryDate || payload.card?.cardExpiryDate;
        const status = payload.status || payload.card?.status;
        const customFields = payload.customFields || payload.card?.customFields;

        console.log('Extracted cardNumber:', cardNumber);
        console.log('Extracted productCode:', productCode);

        // Resolve client and account
        let wasCreated = false;
        const result = await this.prisma.$transaction(async (tx) => {
            const clientId = await this.resolveClientIdFromPayload(payload, tx);
            const accountId = await this.resolveAccountIdFromPayload(payload, clientId, tx);

            // Debug/log resolved identifiers to help trace account linking issues
            console.log('CardService: resolved clientId =', clientId, 'accountId =', accountId);

            // If the caller provided account information but we couldn't resolve a matching account
            // (or the account does not belong to the resolved client), fail fast rather than
            // creating a card with a null accountId.
            const accountProvided = !!(payload.account?.id?.value || payload.card?.accountNumber || (payload as any).accountNumber);
            if (accountProvided && !accountId) {
                throw new NotFoundException('Specified account not found or does not belong to the provided client');
            }

            // upsert card by cardNumber 
            let existingCard = null as any;
            if (cardNumber) {
                existingCard = await tx.card.findUnique({
                    where: { cardNumber: cardNumber }
                });
            }

            try {
                let card;
                if (existingCard) {
                    card = await tx.card.update({
                        where: { id: existingCard.id },
                        data: {
                            cardNumber,
                            productCode,
                            isVirtual,
                            cardExpiryDate: cardExpiryDate || null,
                            clientId: clientId || existingCard.clientId,
                            accountId: accountId || existingCard.accountId,
                        },
                    });
                    wasCreated = false;
                } else {
                    card = await tx.card.create({
                        data: {
                            cardNumber,
                            productCode,
                            isVirtual,
                            cardExpiryDate: cardExpiryDate || null,
                            clientId: clientId || null,
                            accountId: accountId || null,
                        },
                    });
                    wasCreated = true;
                }

                const fullCard = await tx.card.findUnique({
                    where: { id: card.id },
                    include: {
                        client: {
                            select: { id: true, clientId: true, externalClientId: true, firstName: true, lastName: true, email: true }
                        },
                        account: true,
                    },
                });

                // write RequestAudit record for this operation (non-fatal)
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
                                card: {
                                    id: fullCard?.id,
                                    cardNumber: fullCard?.cardNumber,
                                    clientId: fullCard?.clientId,
                                    accountId: fullCard?.accountId,
                                }
                            } as any
                        }
                    });
                } catch (auditErr) {
                    console.warn('Failed to write RequestAudit for card create:', auditErr?.message || auditErr);
                }

                return fullCard;
            } catch (e) {
                // Write audit for failed card create (outside tx) - non fatal
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
                                    message: e?.message,
                                    name: e?.name,
                                    code: e?.code || null
                                }
                            } as any
                        }
                    });
                } catch (auditErr) {
                    console.warn('Failed to write RequestAudit for failed card create:', auditErr?.message || auditErr);
                }

                // wrap Prisma/db errors into an InternalServerError so controller can set proper status
                throw new InternalServerErrorException(e?.message || 'Failed to create/update card');
            }
        });

        return {
            success: true,
            card: result,
            message: wasCreated ? 'Card created successfully' : 'Card already exists',
            wasCreated: wasCreated
        };
    }

    async getCard(cardId: string) {
        const card = await this.prisma.card.findUnique({
            where: { id: cardId },
            include: { client: true, account: true }
        });
        if (!card) throw new NotFoundException('Card not found');
        return { success: true, card, message: 'Card retrieved successfully' };
    }

    async deleteCard(cardId: string) {
        try {
            const deleted = await this.prisma.card.delete({ where: { id: cardId } });
            return { success: true, card: deleted, message: 'Card deleted successfully' };
        } catch (e) {
            // if Prisma throws because not found, convert to NotFoundException
            if (e?.code === 'P2025') throw new NotFoundException('Card not found');
            throw new InternalServerErrorException(e?.message || 'Failed to delete card');
        }
    }
}