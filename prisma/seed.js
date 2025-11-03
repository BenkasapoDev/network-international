const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function main() {
    // Create sample installment plans
    await prisma.installmentPlan.createMany({
        data: [
            {
                installmentPlanId: '00100',
                totalAmount: 1000.00,
                months: 3,
                sourceAccount: 'ACC001',
                destinationAccount: 'ACC002',
                status: 'ACTIVE'
            },
            {
                installmentPlanId: '00166',
                totalAmount: 2000.00,
                months: 6,
                sourceAccount: 'ACC001',
                destinationAccount: 'ACC003',
                status: 'ACTIVE'
            },
            {
                installmentPlanId: '00112',
                totalAmount: 5000.00,
                months: 12,
                sourceAccount: 'ACC001',
                destinationAccount: 'ACC004',
                status: 'ACTIVE'
            }
        ],
        skipDuplicates: true
    })

    // Create sample client
    const client = await prisma.client.upsert({
        where: { externalClientId: 'EXT-SEED-001' },
        update: {},
        create: {
            clientId: 'CLIENT001',
            externalClientId: 'EXT-SEED-001',
            firstName: 'John',
            lastName: 'Doe',
            legalName: 'John Michael Doe',
            email: 'john.doe@example.com',
            phone: '+971501234567'
        }
    })

    // Create personal details
    await prisma.personalDetails.upsert({
        where: { clientId: client.id },
        update: {},
        create: {
            clientId: client.id,
            firstName: 'John',
            lastName: 'Doe',
            gender: 'M',
            title: 'MR',
            middleName: 'Michael',
            citizenship: 'UAE',
            maritalStatus: 'Single',
            dateOfBirth: new Date('1990-01-01'),
            placeOfBirth: 'Dubai',
            language: 'ENG',
            motherName: 'Jane Doe'
        }
    })

    // Create contact details
    await prisma.contactDetails.upsert({
        where: { clientId: client.id },
        update: {},
        create: {
            clientId: client.id,
            mobilePhone: '+971501234567',
            homePhone: '+97142345678',
            email: 'john.doe@example.com'
        }
    })

    // Create address
    await prisma.address.create({
        data: {
            clientId: client.id,
            addressLine1: '123 Main Street',
            addressType: 'PERMANENT',
            addressLine2: 'Apt 4B',
            city: 'Dubai',
            country: 'ARE',
            zip: '12345',
            state: 'Dubai',
            email: 'john.doe@example.com',
            phone: '+971501234567'
        }
    })

    // Create employment details
    await prisma.employmentDetails.upsert({
        where: { clientId: client.id },
        update: {},
        create: {
            clientId: client.id,
            employerName: 'Tech Company Ltd',
            income: 15000.00,
            occupation: 'Software Engineer'
        }
    })

    // Create embossing details
    await prisma.embossingDetails.upsert({
        where: { clientId: client.id },
        update: {},
        create: {
            clientId: client.id,
            title: 'MR',
            firstName: 'John',
            lastName: 'Doe'
        }
    })

    // Create account
    const account = await prisma.account.upsert({
        where: { accountNumber: 'ACC-SEED-001' },
        update: {},
        create: {
            accountNumber: 'ACC-SEED-001',
            clientId: client.id,
            currency: 'AED',
            status: 'ACTIVE',
            openedAt: new Date()
        }
    })

    // Create card
    await prisma.card.upsert({
        where: { cardNumber: '1234567890123456' },
        update: {},
        create: {
            clientId: client.id,
            accountId: account.id,
            cardNumber: '1234567890123456',
            productCode: 'PROD001',
            cardExpiryDate: '1225',
            isVirtual: false
        }
    })

    console.log('Seed data created successfully!')
    console.log({ client, account })
}

main()
    .catch((e) => {
        console.error(e)
        process.exit(1)
    })
    .finally(async () => {
        await prisma.$disconnect()
    })
