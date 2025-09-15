import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import axios from 'axios';

export interface Address {
    addressLine1?: string;
    addressType?: 'PERMANENT' | 'RESIDENT';
    addressLine2?: string;
    addressLine3?: string;
    addressLine4?: string;
    email?: string;
    phone?: string;
    city?: string;
    country?: string;
    zip?: string;
    state?: string;
}

export interface ContactDetails {
    mobilePhone?: string;
    homePhone?: string;
    workPhone?: string;
    email?: string;
}

export interface PersonalDetails {
    firstName?: string;
    lastName?: string;
    gender?: string;
    title?: string;
    middleName?: string;
    citizenship?: string;
    maritalStatus?: string;
    dateOfBirth?: string;
    placeOfBirth?: string;
    language?: string;
    motherName?: string;
}

export interface EmbossingDetails {
    title?: string;
    firstName?: string;
    lastName?: string;
}

export interface IdentityDocument {
    type?: string;
    number?: string;
    expiryDate?: string;
}

export interface EmploymentDetails {
    employerName?: string;
    income?: number;
    occupation?: string;
}

export interface CustomField {
    key?: string;
    value?: string;
}

export interface CreateClientPayload {
    addresses?: Address[];
    contactDetails?: ContactDetails;
    personalDetails?: PersonalDetails;
    embossingDetails?: EmbossingDetails;
    identityProofDocument?: IdentityDocument;
    clientId?: string;
    externalClientId?: string;
    supplementaryDocuments?: IdentityDocument[];
    employmentDetails?: EmploymentDetails;
    responseDetails?: boolean;
    customFields?: CustomField[];

    // Legacy fields for backward compatibility
    body?: {
        id?: string;
        customer_id?: string;
        first_name?: string;
        last_name?: string;
        legal_name?: string;
        email?: string;
        phone?: string;
        accounts?: Array<{
            account_identifier?: string;
            currency?: string;
            status?: string;
            metadata?: any;
        }>;
        cards?: Array<{
            external_card_id?: string;
            masked_card_number?: string;
            product_code?: string;
            product_name?: string;
            card_role?: string;
            is_virtual?: boolean;
            card_expiry_date?: string;
            status?: string;
            custom_fields?: any;
        }>;
    };
    request_client_create?: {
        body?: any;
    };
}

@Injectable()
export class ClientService {
    private readonly externalApiBase: string;

    constructor(private prisma: PrismaService) {
        this.externalApiBase = process.env.EXTERNAL_API_BASE || 'https://api-sandbox.network.global';
    }

    async createClient(payload: CreateClientPayload) {
        console.log('ClientService.createClient called with payload:', JSON.stringify(payload, null, 2));

        try {
            // Call external API first
            console.log('Calling external API:', `${this.externalApiBase}/V2/cardservices/ClientCreate`);
            const externalResponse = await axios.post(
                `${this.externalApiBase}/V2/cardservices/ClientCreate`,
                payload,
                {
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    timeout: 30000,
                }
            );

            console.log('External API response:', JSON.stringify(externalResponse.data, null, 2));

            // Extract authoritative response data
            let responseData = externalResponse.data?.request_client_create?.body ||
                externalResponse.data ||
                payload;

            console.log('Using responseData for DB writes:', JSON.stringify(responseData, null, 2));

            // Derive customer ID from multiple possible sources
            const customerId = payload.clientId ||
                payload.externalClientId ||
                responseData.clientId ||
                responseData.externalClientId ||
                responseData.customer_id ||
                payload.body?.customer_id;

            if (!customerId) {
                throw new Error('No clientId/customer_id found in payload or external response');
            }

            // Perform DB transaction
            const result = await this.prisma.$transaction(async (tx) => {
                // Extract client data from personalDetails and other sources
                const personalDetails = payload.personalDetails || {};
                const contactDetails = payload.contactDetails || {};
                const primaryAddress = payload.addresses?.find(addr => addr.addressType === 'PERMANENT') ||
                    payload.addresses?.[0] || {};

                // Determine primary email and phone
                const primaryEmail = contactDetails.email || primaryAddress.email || payload.body?.email;
                const primaryPhone = contactDetails.mobilePhone ||
                    contactDetails.homePhone ||
                    primaryAddress.phone ||
                    payload.body?.phone;

                // Upsert client with comprehensive data
                const client = await tx.client.upsert({
                    where: { externalId: customerId },
                    update: {
                        firstName: personalDetails.firstName || payload.body?.first_name,
                        lastName: personalDetails.lastName || payload.body?.last_name,
                        legalName: `${personalDetails.firstName || ''} ${personalDetails.middleName || ''} ${personalDetails.lastName || ''}`.trim() || payload.body?.legal_name,
                        email: primaryEmail,
                        phone: primaryPhone,
                    },
                    create: {
                        externalId: customerId,
                        firstName: personalDetails.firstName || payload.body?.first_name,
                        lastName: personalDetails.lastName || payload.body?.last_name,
                        legalName: `${personalDetails.firstName || ''} ${personalDetails.middleName || ''} ${personalDetails.lastName || ''}`.trim() || payload.body?.legal_name,
                        email: primaryEmail,
                        phone: primaryPhone,
                    },
                });

                console.log('Client upserted:', client);

                // Store comprehensive client data in RequestAudit for reference
                await tx.requestAudit.create({
                    data: {
                        requestIdHeader: `client-create-${customerId}`,
                        correlationId: customerId,
                        orgId: 'network-international',
                        srcApp: 'client-service',
                        channel: 'API',
                        timestampHeader: new Date(),
                        rawHeaders: {
                            'Content-Type': 'application/json',
                            'X-Client-Id': customerId
                        },
                        rawBody: {
                            originalPayload: payload,
                            externalResponse: externalResponse.data,
                            personalDetails: personalDetails,
                            contactDetails: contactDetails,
                            addresses: payload.addresses,
                            identityProofDocument: payload.identityProofDocument,
                            supplementaryDocuments: payload.supplementaryDocuments,
                            employmentDetails: payload.employmentDetails,
                            customFields: payload.customFields
                        } as any
                    }
                });

                // Create accounts if provided in legacy format
                const accounts = payload.body?.accounts || [];
                const createdAccounts: any[] = [];
                for (const accountData of accounts) {
                    if (accountData.account_identifier) {
                        const account = await tx.account.upsert({
                            where: { accountIdentifier: accountData.account_identifier },
                            update: {
                                currency: accountData.currency,
                                status: accountData.status,
                                metadata: accountData.metadata,
                                clientId: client.id,
                            },
                            create: {
                                accountIdentifier: accountData.account_identifier,
                                currency: accountData.currency,
                                status: accountData.status,
                                metadata: accountData.metadata,
                                clientId: client.id,
                            },
                        });
                        createdAccounts.push(account);
                    }
                }

                // Create cards if provided in legacy format
                const cards = payload.body?.cards || [];
                const createdCards: any[] = [];
                for (const cardData of cards) {
                    const card = await tx.card.create({
                        data: {
                            externalCardId: cardData.external_card_id,
                            maskedCardNumber: cardData.masked_card_number,
                            productCode: cardData.product_code,
                            productName: cardData.product_name,
                            cardRole: cardData.card_role,
                            isVirtual: cardData.is_virtual || false,
                            cardExpiryDate: cardData.card_expiry_date,
                            status: cardData.status,
                            customFields: cardData.custom_fields,
                            clientId: client.id,
                            accountId: createdAccounts.length > 0 ? createdAccounts[0].id : null,
                        },
                    });
                    createdCards.push(card);
                }

                console.log('Accounts created:', createdAccounts);
                console.log('Cards created:', createdCards);

                return {
                    client,
                    accounts: createdAccounts,
                    cards: createdCards,
                    auditRecord: 'Created in RequestAudit table'
                };
            });

            return {
                success: true,
                external_response: externalResponse.data,
                local_data: result,
                message: 'Client created successfully with comprehensive data',
                client_id: customerId
            };

        } catch (error) {
            console.error('Error in createClient:', error);

            if (error.response) {
                // External API error
                console.error('External API error response:', error.response.data);
                throw new Error(`External API failed: ${error.response.status} - ${JSON.stringify(error.response.data)}`);
            }

            throw error;
        }
    }
}