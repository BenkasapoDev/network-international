#!/usr/bin/env pwsh

Write-Host "Testing NEW card creation with account linking..." -ForegroundColor Yellow

$payload = @{
    account = @{
        id = @{
            value = "0003254540000000391"
            type = "accountNumber"
        }
    }
    card = @{
        productCode = "MASTERCARD"
        cardNumber = "5555444433332222"
        cardExpiryDate = "2028"
        isVirtual = $false
        cardDateOpen = "2025-09-18"
    }
    client = @{
        id = @{
            value = "1234567"
            type = "clientId"
        }
    }
    embossingDetails = @{
        title = "MS"
        firstName = "JANE"
        lastName = "DOE"
    }
    responseDetails = $false
}

$jsonPayload = $payload | ConvertTo-Json -Depth 10

Write-Host "Payload:" -ForegroundColor Cyan
Write-Host $jsonPayload

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/cards/create" -Method POST -Body $jsonPayload -ContentType "application/json"
    
    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
    
    # Check if account is linked
    if ($response.card.accountId) {
        Write-Host "✅ Account linked successfully: $($response.card.accountId)" -ForegroundColor Green
    } else {
        Write-Host "❌ Account is still null!" -ForegroundColor Red
    }
    
    # Check if it's a new card
    if ($response.message -eq "Card created successfully") {
        Write-Host "✅ New card created with proper status code!" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ Existing card updated: $($response.message)" -ForegroundColor Blue
    }
    
} catch {
    Write-Host "❌ FAILED!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}