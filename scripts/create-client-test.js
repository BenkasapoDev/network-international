const { PrismaClient } = require('@prisma/client');
(async function () {
    const p = new PrismaClient();
    try {
        const c = await p.client.create({ data: { clientId: 'SECOND', externalClientId: 'SECOND_EXT', firstName: 'Second' } });
        console.log('Created client:', c.id);
    } catch (e) { console.error(e); process.exit(1); }
    await p.$disconnect();
})();