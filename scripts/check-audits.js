const { PrismaClient } = require('@prisma/client');

async function main() {
    const prisma = new PrismaClient();

    try {
        console.log('Recent RequestAudit entries:');
        const audits = await prisma.requestAudit.findMany({
            orderBy: { createdAt: 'desc' },
            take: 5
        });

        audits.forEach(audit => {
            console.log(`\n--- Audit Entry ---`);
            console.log(`ID: ${audit.id}`);
            console.log(`Request ID: ${audit.requestIdHeader}`);
            console.log(`Correlation ID: ${audit.correlationId}`);
            console.log(`Org ID: ${audit.orgId}`);
            console.log(`Source App: ${audit.srcApp}`);
            console.log(`Channel: ${audit.channel}`);
            console.log(`Timestamp: ${audit.timestampHeader}`);
            console.log(`Created: ${audit.createdAt}`);
            console.log(`Raw Headers:`, JSON.stringify(audit.rawHeaders, null, 2));
        });

    } finally {
        await prisma.$disconnect();
    }
}

main().catch(console.error);