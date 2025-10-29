# Simple Test for Client Resolution
Write-Host "Testing simple client resolution..." -ForegroundColor Green

$baseUrl = "http://localhost:3000"

# Test with a simple payload
$payload = @{
    account = @{
        productCode = "stri"
        accountNumber = "0003254540000000410"
        externalAccountId = "EXT-ACC-410"
        profileCode = "001"
        branchCode = "982"
    }
    client = @{
        id = @{
            value = "string-updated"
            type = "externalClientNumber"
        }
    }
    creditOptions = @{
        creditLimitAmount = 15000
        billingDay = "15"
        directDebitNumber = "DD789"
    }
    debitOptions = @{
        accountType = "Credit"
    }
} | ConvertTo-Json -Depth 10

Write-Host "Payload:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor White
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/accounts/create" -Method POST -Body $payload -ContentType "application/json"
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    Write-Host "Full Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ ERROR:" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    
    try {
        $errorResponse = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "Error Details:" -ForegroundColor Yellow
        $errorResponse | ConvertTo-Json -Depth 10
    } catch {
        Write-Host $_.ErrorDetails.Message -ForegroundColor White
    }
}