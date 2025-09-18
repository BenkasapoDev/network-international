const { PrismaClient } = require('@prisma/client');
(async function () {
    const p = new PrismaClient();
    try {
        const cs = await p.client.findMany({ take: 20 });
        console.log(cs.map(c => ({ id: c.id, clientId: c.clientId, externalClientId: c.externalClientId, firstName: c.firstName })));
    } catch (e) { console.error(e); process.exit(1); }
    await p.$disconnect();
})();