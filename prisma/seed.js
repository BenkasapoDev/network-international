const { PrismaClient } = require('@prisma/client')
const prisma = new PrismaClient()

async function main() {
    // Create sample installment plans
    await prisma.installmentPlan.createMany({
        data: [
            {
                planNumber: '00100',
                planName: '3 Month Plan',
                numberOfPortions: 3,
                interestRate: 5.0,
                isActive: true
            },
            {
                planNumber: '00166',
                planName: '6 Month Plan',
                numberOfPortions: 6,
                interestRate: 8.0,
                isActive: true
            },
            {
                planNumber: '00112',
                planName: '12 Month Plan',
                numberOfPortions: 12,
                interestRate: 12.0,
                isActive: true
            }
        ],
        skipDuplicates: true
    })

    // Create sample customer
    const customer = await prisma.customer.upsert({
        where: { id: 'CUST001' },
        update: {},
        create: {
            id: 'CUST001',
            bankCode: '982',
            externalClientNumber: 'EXT001',
            cardName: 'JOHN DOE',
            cardType: 'CREDIT'
        }
    })

    // Create or update personal details
    await prisma.customerPersonalDetails.upsert({
        where: { customerId: customer.id },
        update: {
            gender: 'M',
            title: 'Mr',
            firstName: 'JOHN',
            lastName: 'DOE',
            citizenship: 'UAE',
            dateOfBirth: new Date('1990-01-01'),
            language: 'ENG'
        },
        create: {
            customerId: customer.id,
            gender: 'M',
            title: 'Mr',
            firstName: 'JOHN',
            lastName: 'DOE',
            citizenship: 'UAE',
            dateOfBirth: new Date('1990-01-01'),
            language: 'ENG'
        }
    })

    // Create or update contact details
    await prisma.customerContactDetails.upsert({
        where: { customerId: customer.id },
        update: {
            mobilePhone: '+971501234567',
            email: 'john.doe@example.com'
        },
        create: {
            customerId: customer.id,
            mobilePhone: '+971501234567',
            email: 'john.doe@example.com'
        }
    })

    // Create account
    const account = await prisma.account.upsert({
        where: { accountNumber: 'ACC001' },
        update: {},
        create: {
            accountNumber: 'ACC001',
            customerId: customer.id,
            branchCode: '001',
            productCode: 'PROD001',
            currency: 'AED',
            accountType: 'CURRENT',
            accountRole: 'PRIMARY'
        }
    })

    // Create card
    const card = await prisma.card.upsert({
        where: { id: 'CARD001' },
        update: {},
        create: {
            id: 'CARD001',
            identifierType: 'CONTRACT_NUMBER',
            customerId: customer.id,
            accountNumber: account.accountNumber,
            institutionId: '982',
            cardholderName: 'JOHN DOE',
            productCode: 'PROD001',
            cardRole: 'P',
            currency: 'AED',
            virtualIndicator: 'P',
            expiryDate: '2025',
            sequenceNumber: '01',
            maskedPan: '1234****5678',
            dateOpen: new Date(),
            activationDate: new Date()
        }
    })

    console.log('Seed data created successfully!')
    console.log({ customer, account, card })
}

main()
    .catch((e) => {
        console.error(e)
        process.exit(1)
    })
    .finally(async () => {
        await prisma.$disconnect()
    })
