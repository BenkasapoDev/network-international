$payload = @{
    "card" = @{
        "productCode" = "VISA"
        "cardNumber" = "4111111111111111"
        "cardExpiryDate" = "2812"
        "isVirtual" = $true
        "cardDateOpen" = "2023-01-01"
    }
    "client" = @{
        "id" = @{
            "value" = "TEST123"
            "type" = "externalClientNumber"
        }
    }
} | ConvertTo-Json -Depth 5

Write-Host "Testing simple card create..."
Write-Host "Payload:"
Write-Host $payload

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/cards/create" -Method POST -ContentType "application/json" -Body $payload
    Write-Host "✅ SUCCESS"
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Host "❌ ERROR"
    Write-Host $_.Exception.Message
    if ($_.ErrorDetails) {
        Write-Host $_.ErrorDetails.Message
    }
}