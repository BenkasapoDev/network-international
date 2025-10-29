# Test Account Upsert with Existing Data
Write-Host "Testing account upsert with existing externalAccountId..." -ForegroundColor Green

$baseUrl = "http://localhost:3000"
$endpoint = "/accounts/create"

# Test payload with existing externalAccountId (should update, not fail)
$payload = @{
    account = @{
        productCode = "stri-updated"
        accountNumber = "0003254540000000395"
        externalAccountId = "00112211221123"  # This already exists
        profileCode = "002"  # Updated
        branchCode = "983"   # Updated
    }
    client = @{
        id = @{
            value = "string-updated"
            type = "stringstring"
            additionalQualifiers = @(
                @{
                    value = "str"
                    type = "string"
                },
                @{
                    value = "string"
                    type = "string"
                }
            )
        }
    }
    creditOptions = @{
        creditLimitAmount = 25000  # Updated
        billingDay = "5"           # Updated
        directDebitNumber = "string-updated"
    }
    debitOptions = @{
        accountType = "Debit"      # Updated
    }
    responseDetails = $false
    customFields = @(
        @{
            key = "XXX"
            value = "XXX"
        },
        @{
            key = "YYY"
            value = "YYY"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Upsert Test Payload:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor White
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method POST -Body $payload -ContentType "application/json"
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "Response:" -ForegroundColor Yellow

    try {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        $errorResponse | ConvertTo-Json -Depth 10
    } catch {
        Write-Host $_.ErrorDetails.Message -ForegroundColor White
    }
}