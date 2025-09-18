# Test Client Resolution for Account Creation
Write-Host "Testing account creation with client resolution..." -ForegroundColor Green

$baseUrl = "http://localhost:3000"

# First, create a client to link the account to
Write-Host "Step 1: Creating a client..." -ForegroundColor Yellow
$clientPayload = @{
    externalClientId = "EXT-CLIENT-001"
    personalDetails = @{
        firstName = "John"
        lastName = "Doe"
        dateOfBirth = "1990-01-01"
    }
    contactDetails = @{
        email = "john.doe@example.com"
        mobilePhone = "+971501234567"
    }
    identityProofDocument = @{
        type = "passport"
        number = "A1234567890"
        expiryDate = "2030-12-31"
    }
} | ConvertTo-Json -Depth 10

try {
    $clientResponse = Invoke-RestMethod -Uri "$baseUrl/clients/create" -Method POST -Body $clientPayload -ContentType "application/json"
    Write-Host "✅ Client created successfully!" -ForegroundColor Green
    $createdClientId = $clientResponse.client_id
    Write-Host "Client ID: $createdClientId" -ForegroundColor White
} catch {
    Write-Host "⚠️ Client creation failed or client already exists" -ForegroundColor Yellow
    $createdClientId = "EXT-CLIENT-001"
}

Write-Host ""
Write-Host "Step 2: Creating account with client resolution..." -ForegroundColor Yellow

# Test different client ID types
$testCases = @(
    @{
        name = "By externalClientNumber"
        type = "externalClientNumber"
        value = "EXT-CLIENT-001"
        accountNumber = "0003254540000000400"
    },
    @{
        name = "By identityProofDocument"
        type = "identityProofDocument" 
        value = "A1234567890"
        accountNumber = "0003254540000000401"
    }
)

foreach ($testCase in $testCases) {
    Write-Host ""
    Write-Host "Testing: $($testCase.name)" -ForegroundColor Cyan
    
    $accountPayload = @{
        account = @{
            productCode = "stri"
            accountNumber = $testCase.accountNumber
            externalAccountId = "EXT-ACC-$(Get-Random)"
            profileCode = "001"
            branchCode = "982"
        }
        client = @{
            id = @{
                value = $testCase.value
                type = $testCase.type
                additionalQualifiers = @(
                    @{
                        value = "additional-info"
                        type = "info"
                    }
                )
            }
        }
        creditOptions = @{
            creditLimitAmount = 30000
            billingDay = "10"
            directDebitNumber = "DD123456"
        }
        debitOptions = @{
            accountType = "Credit"
        }
        responseDetails = $false
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/accounts/create" -Method POST -Body $accountPayload -ContentType "application/json"
        Write-Host "✅ SUCCESS!" -ForegroundColor Green
        Write-Host "Account ID: $($response.account.id)" -ForegroundColor White
        Write-Host "Client ID: $($response.account.clientId)" -ForegroundColor White
        Write-Host "Client Info: $($response.account.client.firstName) $($response.account.client.lastName)" -ForegroundColor White
    } catch {
        Write-Host "❌ ERROR:" -ForegroundColor Red
        try {
            $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
            Write-Host $errorResponse.message -ForegroundColor White
        } catch {
            Write-Host $_.ErrorDetails.Message -ForegroundColor White
        }
    }
}