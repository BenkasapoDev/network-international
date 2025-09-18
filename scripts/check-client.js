const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
(async () => {
    const id = process.argv[2];
    const client = await prisma.client.findUnique({ where: { id } });
    console.log(client);
    await prisma.$disconnect();
})();
