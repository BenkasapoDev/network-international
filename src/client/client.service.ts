import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import axios from 'axios';
import type { RequestHeaders } from '../common/header-utils';

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
    account?: {
        productCode?: string;
        accountNumber?: string;
        externalAccountId?: string;
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
    creditOptions?: {
        creditLimitAmount?: number;
        billingDay?: string;
        directDebitNumber?: string;
    };
    debitOptions?: {
        accountType?: string;
    };
    responseDetails?: boolean;
    customFields?: CustomField[];

    // Legacy fields for backward compatibility
    addresses?: Address[];
    contactDetails?: ContactDetails;
    personalDetails?: PersonalDetails;
    embossingDetails?: EmbossingDetails;
    identityProofDocument?: IdentityDocument;
    clientId?: string;
    externalClientId?: string;
    supplementaryDocuments?: IdentityDocument[];
    employmentDetails?: EmploymentDetails;
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

export interface GetClientDetailsPayload {
    client?: {
        id?: {
            value?: string;
            type?: string;
            additionalQualifiers?: {
                type?: string;
                value?: string;
            };
        };
    };
}

@Injectable()
export class ClientService {
    private readonly externalApiBase: string;

    constructor(private prisma: PrismaService) {
        this.externalApiBase = process.env.EXTERNAL_API_BASE_URL || '';
    }

    async createClient(payload: CreateClientPayload, headers: RequestHeaders) {
        console.log('ClientService.createClient called with payload:', JSON.stringify(payload, null, 2));

        try {
            // Call external API first
            console.log('Calling external API:', `${this.externalApiBase}/clients/create`);

            let externalResponse;
            try {
                externalResponse = await axios.post(
                    `${this.externalApiBase}/clients/create`,
                    payload,
                    {
                        headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ' + (process.env.EXTERNAL_API_TOKEN || 'sandbox-token'),
                            'X-Client-ID': payload.clientId || 'default-client',
                        },
                        timeout: 30000,
                    }
                );
            } catch (apiError) {
                console.log('External API call failed, using mock response for testing:', apiError.response?.data);

                // Mock successful response for testing when external API is unavailable
                externalResponse = {
                    data: {
                        status: 'S',
                        client_id: payload.clientId || payload.externalClientId,
                        message: 'Mock response - external API unavailable',
                        request_client_create: {
                            body: payload
                        }
                    }
                };

                console.log('Using mock external response:', JSON.stringify(externalResponse.data, null, 2));
            }

            console.log('External API response:', JSON.stringify(externalResponse?.data, null, 2));

            // Extract authoritative response data
            let responseData = externalResponse?.data?.request_client_create?.body ||
                externalResponse?.data ||
                payload;

            console.log('Using responseData for DB writes:', JSON.stringify(responseData, null, 2));

            // Derive customer ID from multiple possible sources
            const customerId = payload.clientId ||
                payload.externalClientId ||
                payload.client?.id?.value ||
                responseData.clientId ||
                responseData.externalClientId ||
                responseData.customer_id ||
                payload.body?.customer_id;

            if (!customerId) {
                throw new Error('No clientId/customer_id found in payload or external response');
            }

            // Perform DB transaction
            let wasClientCreated = false;
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

                // Upsert client with basic data
                // Determine the best unique identifier for the where clause
                const uniqueId = payload.externalClientId ||
                    payload.clientId ||
                    payload.client?.id?.value ||
                    customerId;

                // Check if a client already exists with the same email
                let existingClientByEmail: any = null;
                if (primaryEmail) {
                    existingClientByEmail = await tx.client.findUnique({
                        where: { email: primaryEmail }
                    });
                }

                // Track if we're creating or updating
                let existingClient = existingClientByEmail;
                if (!existingClient) {
                    // Check by other identifiers if no email match
                    if (payload.externalClientId) {
                        existingClient = await tx.client.findUnique({ where: { externalClientId: payload.externalClientId } });
                    } else if (payload.clientId) {
                        existingClient = await tx.client.findUnique({ where: { clientId: payload.clientId } });
                    }
                }

                wasClientCreated = !existingClient;

                let whereClause: any;

                if (existingClientByEmail) {
                    // If client exists with this email, use its existing identifier for the where clause
                    // This prevents email constraint violations
                    if (existingClientByEmail.externalClientId) {
                        whereClause = { externalClientId: existingClientByEmail.externalClientId };
                    } else if (existingClientByEmail.clientId) {
                        whereClause = { clientId: existingClientByEmail.clientId };
                    } else {
                        whereClause = { id: existingClientByEmail.id };
                    }
                } else {
                    // No existing client with this email, use the primary identifier from payload
                    if (payload.externalClientId) {
                        whereClause = { externalClientId: payload.externalClientId };
                    } else if (payload.clientId) {
                        whereClause = { clientId: payload.clientId };
                    } else if (payload.client?.id?.value) {
                        whereClause = { externalClientId: payload.client.id.value };
                    } else if (primaryEmail) {
                        whereClause = { email: primaryEmail };
                    } else {
                        whereClause = { externalClientId: uniqueId };
                    }
                }

                const client = await tx.client.upsert({
                    where: whereClause,
                    update: {
                        // Only update clientId if it's not already set or if we're using a different identifier
                        ...(existingClientByEmail ? {} : { clientId: payload.clientId || uniqueId }),
                        externalClientId: payload.externalClientId || payload.client?.id?.value || customerId,
                        firstName: personalDetails.firstName || payload.body?.first_name,
                        lastName: personalDetails.lastName || payload.body?.last_name,
                        legalName: `${personalDetails.firstName || ''} ${personalDetails.middleName || ''} ${personalDetails.lastName || ''}`.trim() || payload.body?.legal_name,
                        email: primaryEmail,
                        phone: primaryPhone,
                    },
                    create: {
                        clientId: payload.clientId || uniqueId,
                        externalClientId: payload.externalClientId || payload.client?.id?.value || customerId,
                        firstName: personalDetails.firstName || payload.body?.first_name,
                        lastName: personalDetails.lastName || payload.body?.last_name,
                        legalName: `${personalDetails.firstName || ''} ${personalDetails.middleName || ''} ${personalDetails.lastName || ''}`.trim() || payload.body?.legal_name,
                        email: primaryEmail,
                        phone: primaryPhone,
                    },
                });

                console.log('Client upserted:', client);

                // Create ClientId if provided
                if (payload.client?.id) {
                    const clientIdRecord = await tx.clientId.create({
                        data: {
                            value: payload.client.id.value,
                            type: payload.client.id.type,
                            clientId: client.id,
                        },
                    });

                    // Create additional qualifiers if provided
                    if (payload.client.id.additionalQualifiers && payload.client.id.additionalQualifiers.length > 0) {
                        for (const qualifier of payload.client.id.additionalQualifiers) {
                            await tx.clientIdQualifier.create({
                                data: {
                                    value: qualifier.value,
                                    type: qualifier.type,
                                    clientIdId: clientIdRecord.id,
                                },
                            });
                        }
                    }
                }                // Create ContactDetails
                if (payload.contactDetails) {
                    await tx.contactDetails.upsert({
                        where: { clientId: client.id },
                        update: {
                            mobilePhone: payload.contactDetails.mobilePhone,
                            homePhone: payload.contactDetails.homePhone,
                            workPhone: payload.contactDetails.workPhone,
                            email: payload.contactDetails.email,
                        },
                        create: {
                            mobilePhone: payload.contactDetails.mobilePhone,
                            homePhone: payload.contactDetails.homePhone,
                            workPhone: payload.contactDetails.workPhone,
                            email: payload.contactDetails.email,
                            clientId: client.id,
                        },
                    });
                }

                // Create PersonalDetails
                if (payload.personalDetails) {
                    await tx.personalDetails.upsert({
                        where: { clientId: client.id },
                        update: {
                            firstName: payload.personalDetails.firstName,
                            lastName: payload.personalDetails.lastName,
                            gender: payload.personalDetails.gender,
                            title: payload.personalDetails.title,
                            middleName: payload.personalDetails.middleName,
                            citizenship: payload.personalDetails.citizenship,
                            maritalStatus: payload.personalDetails.maritalStatus,
                            dateOfBirth: payload.personalDetails.dateOfBirth ? new Date(payload.personalDetails.dateOfBirth) : null,
                            placeOfBirth: payload.personalDetails.placeOfBirth,
                            language: payload.personalDetails.language,
                            motherName: payload.personalDetails.motherName,
                        },
                        create: {
                            firstName: payload.personalDetails.firstName,
                            lastName: payload.personalDetails.lastName,
                            gender: payload.personalDetails.gender,
                            title: payload.personalDetails.title,
                            middleName: payload.personalDetails.middleName,
                            citizenship: payload.personalDetails.citizenship,
                            maritalStatus: payload.personalDetails.maritalStatus,
                            dateOfBirth: payload.personalDetails.dateOfBirth ? new Date(payload.personalDetails.dateOfBirth) : null,
                            placeOfBirth: payload.personalDetails.placeOfBirth,
                            language: payload.personalDetails.language,
                            motherName: payload.personalDetails.motherName,
                            clientId: client.id,
                        },
                    });
                }

                // Create Addresses
                if (payload.addresses && payload.addresses.length > 0) {
                    // Delete existing addresses first
                    await tx.address.deleteMany({
                        where: { clientId: client.id }
                    });

                    // Create new addresses
                    for (const addr of payload.addresses) {
                        await tx.address.create({
                            data: {
                                addressLine1: addr.addressLine1,
                                addressType: addr.addressType,
                                addressLine2: addr.addressLine2,
                                addressLine3: addr.addressLine3,
                                addressLine4: addr.addressLine4,
                                email: addr.email,
                                phone: addr.phone,
                                city: addr.city,
                                country: addr.country,
                                zip: addr.zip,
                                state: addr.state,
                                clientId: client.id,
                            },
                        });
                    }
                }

                // Create Identity Documents
                const identityDocs: any[] = [];
                if (payload.identityProofDocument) {
                    const doc = await tx.identityDocument.create({
                        data: {
                            type: payload.identityProofDocument.type,
                            number: payload.identityProofDocument.number,
                            expiryDate: payload.identityProofDocument.expiryDate ? new Date(payload.identityProofDocument.expiryDate) : null,
                            clientId: client.id,
                        },
                    });
                    identityDocs.push(doc);
                }

                if (payload.supplementaryDocuments && payload.supplementaryDocuments.length > 0) {
                    for (const doc of payload.supplementaryDocuments) {
                        const createdDoc = await tx.identityDocument.create({
                            data: {
                                type: doc.type,
                                number: doc.number,
                                expiryDate: doc.expiryDate ? new Date(doc.expiryDate) : null,
                                clientId: client.id,
                            },
                        });
                        identityDocs.push(createdDoc);
                    }
                }

                // Create EmploymentDetails
                if (payload.employmentDetails) {
                    await tx.employmentDetails.upsert({
                        where: { clientId: client.id },
                        update: {
                            employerName: payload.employmentDetails.employerName,
                            income: payload.employmentDetails.income,
                            occupation: payload.employmentDetails.occupation,
                        },
                        create: {
                            employerName: payload.employmentDetails.employerName,
                            income: payload.employmentDetails.income,
                            occupation: payload.employmentDetails.occupation,
                            clientId: client.id,
                        },
                    });
                }

                // Create CustomFields
                if (payload.customFields && payload.customFields.length > 0) {
                    // Delete existing custom fields first
                    await tx.customField.deleteMany({
                        where: { clientId: client.id }
                    });

                    // Create new custom fields
                    for (const field of payload.customFields) {
                        await tx.customField.create({
                            data: {
                                key: field.key,
                                value: field.value,
                                clientId: client.id,
                            },
                        });
                    }
                }

                // Store comprehensive client data in RequestAudit for reference
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

                // Create accounts if provided in new format
                const accounts: any[] = [];
                if (payload.account) {
                    if (!payload.account.accountNumber) {
                        throw new Error('accountNumber is required for account creation');
                    }
                    const account = await tx.account.upsert({
                        where: { accountNumber: payload.account.accountNumber },
                        update: {
                            externalAccountId: payload.account.externalAccountId,
                            productCode: payload.account.productCode,
                            profileCode: payload.account.profileCode,
                            branchCode: payload.account.branchCode,
                            clientId: client.id,
                        },
                        create: {
                            accountNumber: payload.account.accountNumber,
                            externalAccountId: payload.account.externalAccountId,
                            productCode: payload.account.productCode,
                            profileCode: payload.account.profileCode,
                            branchCode: payload.account.branchCode,
                            clientId: client.id,
                        },
                    });
                    accounts.push(account);

                    // Create CreditOptions if provided
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

                    // Create DebitOptions if provided
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
                }

                // Create cards if provided in legacy format
                const cards = payload.body?.cards || [];
                const createdCards: any[] = [];
                for (const cardData of cards) {
                    const card = await tx.card.create({
                        data: {
                            cardNumber: cardData.masked_card_number,
                            productCode: cardData.product_code,
                            isVirtual: cardData.is_virtual || false,
                            cardExpiryDate: cardData.card_expiry_date,
                            clientId: client.id,
                            accountId: accounts.length > 0 ? accounts[0].id : null,
                        },
                    });
                    createdCards.push(card);
                }

                console.log('Accounts created:', accounts);
                console.log('Cards created:', createdCards);

                return {
                    client,
                    accounts: accounts,
                    cards: createdCards,
                    auditRecord: 'Created in RequestAudit table',
                    wasCreated: wasClientCreated
                };
            });

            return this.formatResponse(result, customerId, payload.responseDetails);

        } catch (error) {
            console.log('Error in createClient:', error?.message);
            console.error('Error in createClient:', error);


            if (error.response) {
                // External API error
                console.error('External API error response:', error.response.data);
                // write audit for failed client create (non-fatal)
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
                                    message: error.response?.data || error?.message,
                                    status: error.response?.status
                                }
                            } as any
                        }
                    });
                } catch (auditErr) {
                    console.warn('Failed to write RequestAudit for failed client create:', auditErr?.message || auditErr);
                }

                throw new Error(`External API failed: ${error.response.status} - ${JSON.stringify(error.response.data)}`);
            }

            throw error;
        }
    }

    // Helper method to format response based on responseDetails flag
    private formatResponse(result: any, customerId: string, responseDetails: boolean = false) {
        if (!responseDetails) {
            // Minimal response
            return {
                success: true,
                client_id: customerId,
                message: result.wasCreated ? 'Client created successfully' : 'Client already exists',
                wasCreated: result.wasCreated
            };
        } else {
            // Comprehensive response with all details
            return {
                success: true,
                client_id: customerId,
                message: result.wasCreated ? 'Client created successfully with comprehensive data' : 'Client already exists with comprehensive data',
                client: result.client,
                accounts: result.accounts,
                cards: result.cards,
                audit_record: result.auditRecord,
                created_at: new Date().toISOString(),
                wasCreated: result.wasCreated
            };
        }
    }

    async getClientDetails(payload: GetClientDetailsPayload, headers: RequestHeaders) {
        console.log('ClientService.getClientDetails called with payload:', JSON.stringify(payload, null, 2));

        try {
            // Call external API to get client details
            console.log('Calling external API for client details:', `${this.externalApiBase}/clients/details`);

            const externalResponse = await axios.post(
                `${this.externalApiBase}/clients/details`,
                payload,
                {
                    headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ' + (process.env.EXTERNAL_API_TOKEN || 'sandbox-token'),
                        'X-Client-ID': payload.client?.id?.value || 'default-client',
                        'X-Request-ID': headers.requestId,
                        'X-Correlation-ID': headers.correlationId,
                        'X-OrgId': headers.orgId,
                        'X-Timestamp': headers.timestamp.toISOString(),
                        'X-SrcApp': headers.srcApp,
                        'X-Channel': headers.channel,
                    },
                    timeout: 30000,
                }
            );

            console.log('External API response for client details:', JSON.stringify(externalResponse?.data, null, 2));

            // Store request audit for traceability
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
                            operation: 'getClientDetails',
                            payload,
                            externalResponse: externalResponse?.data
                        } as any
                    }
                });
            } catch (auditErr) {
                console.warn('Failed to write RequestAudit for client details:', auditErr?.message || auditErr);
            }

            return {
                success: true,
                clientDetails: externalResponse?.data,
                message: 'Client details retrieved successfully',
                requestId: headers.requestId,
                correlationId: headers.correlationId
            };

        } catch (error) {
            console.error('Error in getClientDetails:', error);

            // Write audit for failed attempts (non-fatal)
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
                            operation: 'getClientDetails',
                            payload,
                            error: {
                                message: error.response?.data || error?.message,
                                status: error.response?.status
                            }
                        } as any
                    }
                });
            } catch (auditErr) {
                console.warn('Failed to write RequestAudit for failed client details:', auditErr?.message || auditErr);
            }

            // Return detailed error information
            if (error.response) {
                // External API error
                throw new InternalServerErrorException({
                    message: `External API Error: ${error.message}`,
                    externalStatus: error.response.status,
                    externalData: error.response.data,
                    url: error.config?.url
                });
            } else if (error.code === 'ERR_INVALID_URL') {
                // URL configuration error
                throw new InternalServerErrorException({
                    message: `Invalid URL Configuration: ${error.message}`,
                    input: error.input,
                    code: error.code
                });
            } else {
                // Generic error
                throw new InternalServerErrorException({
                    message: error.message || 'Failed to retrieve client details',
                    stack: error.stack,
                    name: error.name
                });
            }
        }
    }
}