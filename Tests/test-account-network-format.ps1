# Test Account Creation with Network International Format
Write-Host "Testing account creation with Network International format..." -ForegroundColor Green

$baseUrl = "http://localhost:3000"
$endpoint = "/accounts/create"

# Test payload in Network International format (nested structure)
$payload = @{
    account = @{
        productCode = "stri"
        accountNumber = "0003254540000000399"
        externalAccountId = "00112211221125"
        profileCode = "001"
        branchCode = "982"
    }
    client = @{
        id = @{
            value = "test-client-125"
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
        creditLimitAmount = 20000
        billingDay = "1"
        directDebitNumber = "string"
    }
    debitOptions = @{
        accountType = "Credit"
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

Write-Host "Network International Format Payload:" -ForegroundColor Yellow
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