#!/usr/bin/env pwsh

Write-Host "Testing header processing with client creation..." -ForegroundColor Yellow

$headers = @{
    "X-Request-ID" = "test123456"
    "X-Correlation-ID" = "corr789012"
    "X-OrgId" = "TESTORG"
    "X-Timestamp" = "2025-10-03T10:00:00Z"
    "X-SrcApp" = "test-app"
    "X-Channel" = "Client"
}

$payload = @{
    client = @{
        id = @{
            value = "TEST_CLIENT"
            type = "clientId"
        }
    }
    account = @{
        productCode = "TEST"
        accountNumber = "9999999999999999"
    }
    responseDetails = $false
}

$jsonPayload = $payload | ConvertTo-Json -Depth 10

Write-Host "Headers:" -ForegroundColor Cyan
$headers | ConvertTo-Json

Write-Host "Payload:" -ForegroundColor Cyan
Write-Host $jsonPayload

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/clients/create" -Method POST -Body $jsonPayload -ContentType "application/json" -Headers $headers

    Write-Host "✅ SUCCESS!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10

} catch {
    Write-Host "❌ FAILED!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}