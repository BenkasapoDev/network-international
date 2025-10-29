Write-Host "Testing card create..." -ForegroundColor Green

$baseUrl = "http://localhost:3000"
$endpoint = "/cards/create"

$payload = @{
    card = @{
        cardNumber = "4111111111111111"
        productCode = "VISA"
        isVirtual = $false
        cardExpiryDate = "2027-12-31"
        cardDateOpen = "2025-09-17"
        accountNumber = "0003254540000000420"
    }
    client = @{
        id = @{
            value = "SECOND_EXT"
            type = "externalClientNumber"
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "Payload:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor White

try {
    $response = Invoke-RestMethod -Uri "$baseUrl$endpoint" -Method POST -Body $payload -ContentType "application/json"
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
} catch {
    Write-Host "❌ ERROR" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor White
}
