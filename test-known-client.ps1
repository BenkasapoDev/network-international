# Test with Known Client
Write-Host "Testing with known client..." -ForegroundColor Green

$baseUrl = "http://localhost:3000"

# First, let's create a client we can reference
Write-Host "Creating a test client..." -ForegroundColor Yellow
$clientPayload = @{
    externalClientId = "TEST-CLIENT-123"
    personalDetails = @{
        firstName = "Jane"
        lastName = "Smith"
        dateOfBirth = "1985-06-15"
    }
    contactDetails = @{
        email = "jane.smith@example.com"
        mobilePhone = "+971509876543"
    }
    identityProofDocument = @{
        type = "national_id"
        number = "784199012345678"
        expiryDate = "2030-12-31"
    }
} | ConvertTo-Json -Depth 10

try {
    $clientResponse = Invoke-RestMethod -Uri "$baseUrl/clients/create" -Method POST -Body $clientPayload -ContentType "application/json"
    Write-Host "✅ Client created!" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Client might already exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Now testing account creation with this client..." -ForegroundColor Yellow

# Test account creation with this known client
$accountPayload = @{
    account = @{
        productCode = "stri"
        accountNumber = "0003254540000000420"
        externalAccountId = "EXT-ACC-420"
        profileCode = "001"
        branchCode = "982"
    }
    client = @{
        id = @{
            value = "TEST-CLIENT-123"
            type = "externalClientNumber"
        }
    }
    creditOptions = @{
        creditLimitAmount = 20000
        billingDay = "20"
        directDebitNumber = "DD123"
    }
    debitOptions = @{
        accountType = "Credit"
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/accounts/create" -Method POST -Body $accountPayload -ContentType "application/json"
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Account Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    try {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Error: $($errorResponse.message)" -ForegroundColor White
    } catch {
        Write-Host $_.ErrorDetails.Message -ForegroundColor White
    }
}