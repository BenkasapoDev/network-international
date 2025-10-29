# Test Account Creation
Write-Host "Testing account creation..." -ForegroundColor Green

$baseUrl = "http://localhost:3000"
$endpoint = "/accounts/create"

# Test payload for account creation
$payload = @{
    accountNumber = "0003254540000000398"
    externalAccountId = "00112211221124"
    productCode = "stri"
    profileCode = "001"
    branchCode = "982"
    clientId = "test-client-124"
    creditOptions = @{
        creditLimitAmount = 30000
        billingDay = "20"
        directDebitNumber = "string2"
    }
    debitOptions = @{
        accountType = "Credit"
    }
} | ConvertTo-Json

Write-Host "Payload:" -ForegroundColor Yellow
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