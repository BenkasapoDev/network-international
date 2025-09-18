import { PrismaClient } from '@prisma/client';

export async function resolveClientIdFromPayload(payload: any, prismaTx: any) {
    // prismaTx should be an instance of PrismaClient or a transaction client
    if (!prismaTx) throw new Error('prisma client required');

    // direct clientId override
    let clientId = (payload as any)?.clientId || null;

    const clientIdObj = payload?.client?.id;
    if (!clientId && clientIdObj) {
        const t = clientIdObj.type;
        const v = clientIdObj.value;

        switch (t) {
            case 'clientId': {
                const c1 = await prismaTx.client.findFirst({ where: { clientId: v } });
                clientId = c1?.id || null;
                // If not found and value looks like a UUID, attempt direct primary id lookup
                if (!clientId) {
                    const isUuid = typeof v === 'string' && /^[0-9a-fA-F-]{36}$/.test(v);
                    if (isUuid) {
                        const cByPk = await prismaTx.client.findUnique({ where: { id: v } });
                        clientId = cByPk?.id || null;
                    }
                }
                break;
            }
            case 'externalClientNumber': {
                const c2 = await prismaTx.client.findFirst({ where: { externalClientId: v } });
                clientId = c2?.id || null;
                break;
            }
            case 'identityProofDocument': {
                const c3 = await prismaTx.client.findFirst({ where: { identityDocuments: { some: { number: v } } } });
                clientId = c3?.id || null;
                break;
            }
            case 'accountNumber': {
                const c4 = await prismaTx.client.findFirst({ where: { accounts: { some: { accountNumber: v } } } });
                clientId = c4?.id || null;
                break;
            }
            case 'cardNumber': {
                // Card model uses `cardNumber` in Prisma schema
                const c5 = await prismaTx.client.findFirst({ where: { cards: { some: { cardNumber: v } } } });
                clientId = c5?.id || null;
                break;
            }
            case 'contractNumber': {
                const c6 = await prismaTx.client.findFirst({ where: { contracts: { some: { contractNumber: v } } } });
                clientId = c6?.id || null;
                break;
            }
            default: {
                const c7 = await prismaTx.client.findFirst({ where: { clientId: v } });
                clientId = c7?.id || null;
                break;
            }
        }
    }

    return clientId;
}

export default resolveClientIdFromPayload;
