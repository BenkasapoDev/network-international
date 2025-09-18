#!/usr/bin/env pwsh

Write-Host "Testing card creation with WRONG client-account combination..." -ForegroundColor Yellow

$payload = @{
    account = @{
        id = @{
            value = "0003254540000000391"
            type = "accountNumber"
        }
    }
    card = @{
        productCode = "VISA"
        cardNumber = "4000111122223333"
        cardExpiryDate = "2029"
        isVirtual = $false
    }
    client = @{
        id = @{
            value = "SECOND_EXT"
            type = "externalClientNumber"
        }
    }
    responseDetails = $false
}

$jsonPayload = $payload | ConvertTo-Json -Depth 10

Write-Host "Payload:" -ForegroundColor Cyan
Write-Host $jsonPayload

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/cards/create" -Method POST -Body $jsonPayload -ContentType "application/json"
    
    Write-Host "❌ UNEXPECTED SUCCESS - This should have failed!" -ForegroundColor Red
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "✅ EXPECTED FAILURE!" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}