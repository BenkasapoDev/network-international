#!/usr/bin/env pwsh

Write-Host "Testing missing required headers..." -ForegroundColor Yellow

# Missing X-Request-ID (required)
$headers = @{
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
    responseDetails = $false
}

$jsonPayload = $payload | ConvertTo-Json -Depth 10

Write-Host "Headers (missing X-Request-ID):" -ForegroundColor Cyan
$headers | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/clients/create" -Method POST -Body $jsonPayload -ContentType "application/json" -Headers $headers

    Write-Host "❌ UNEXPECTED SUCCESS - Should have failed!" -ForegroundColor Red

} catch {
    Write-Host "✅ EXPECTED FAILURE!" -ForegroundColor Green
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}