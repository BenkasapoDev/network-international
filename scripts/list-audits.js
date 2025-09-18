const { PrismaClient } = require('@prisma/client');
(async function () {
    const p = new PrismaClient();
    try {
        const audits = await p.requestAudit.findMany({ orderBy: { createdAt: 'desc' }, take: 10 });
        console.log('Recent audits:', audits.map(a => ({ id: a.id, requestIdHeader: a.requestIdHeader, correlationId: a.correlationId, createdAt: a.createdAt })));
    } catch (e) { console.error(e); process.exit(1); }
    await p.$disconnect();
})();
