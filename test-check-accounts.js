const { PrismaClient } = require('@prisma/client');

async function main() {
    const prisma = new PrismaClient();

    try {
        console.log('Checking all accounts...');
        const accounts = await prisma.account.findMany({
            include: { client: true }
        });

        console.log('All accounts:');
        accounts.forEach(account => {
            console.log(`Account: ${account.accountNumber} | Client: ${account.client.clientId || account.client.externalClientId} | Client ID: ${account.clientId}`);
        });

        console.log('\nChecking clients...');
        const clients = await prisma.client.findMany({
            include: { accounts: true }
        });

        console.log('All clients with accounts:');
        clients.forEach(client => {
            console.log(`Client: ${client.clientId || client.externalClientId} | Accounts: ${client.accounts.length}`);
            client.accounts.forEach(account => {
                console.log(`  - Account: ${account.accountNumber}`);
            });
        });

    } finally {
        await prisma.$disconnect();
    }
}

main().catch(console.error);