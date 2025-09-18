#!/usr/bin/env pwsh

Write-Host "Testing card creation with account linking..." -ForegroundColor Yellow

$payload = @{
    account = @{
        id = @{
            value = "0003254540000000391"
            type = "accountNumber"
            additionalQualifiers = @(
                @{
                    value = "string"
                    type = "string"
                },
                @{
                    value = "stri"
                    type = "string"
                }
            )
        }
    }
    card = @{
        productCode = "string"
        cardNumber = "403185****212235"
        cardExpiryDate = "2812"
        isVirtual = $true
        cardDateOpen = "2023-01-01"
    }
    client = @{
        id = @{
            value = "1234567"
            type = "clientId"
            additionalQualifiers = @(
                @{
                    value = "string"
                    type = "string"
                },
                @{
                    value = "strin"
                    type = "string"
                }
            )
        }
    }
    embossingDetails = @{
        title = "MR"
        firstName = "JAMES"
        lastName = "HERNANDEZ"
    }
    responseDetails = $false
    customFields = @(
        @{
            key = "XXX"
            value = "XXX"
        },
        @{
            key = "XXX"
            value = "XXX"
        }
    )
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
    
} catch {
    Write-Host "❌ FAILED!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}