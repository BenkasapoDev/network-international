# Test with unique data to avoid conflicts

$timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
$uniqueId = "TEST-$timestamp"

$payload = @{
    "clientId" = $uniqueId
    "externalClientId" = "EXT-$uniqueId"
    "responseDetails" = $false
    "personalDetails" = @{
        "firstName" = "TestUser"
        "lastName" = "Example"
        "dateOfBirth" = "1990-01-01"
    }
    "contactDetails" = @{
        "mobilePhone" = "+971501111111"
        "email" = "test.$timestamp@example.com"
    }
    "addresses" = @(
        @{
            "addressType" = "PERMANENT"
            "addressLine1" = "123 Test Street"
            "city" = "Dubai"
            "country" = "ARE"
            "zip" = "12345"
            "state" = "Dubai"
            "phone" = "+971501111111"
            "email" = "test.$timestamp@example.com"
        }
    )
    "employmentDetails" = @{
        "employerName" = "Test Company"
        "occupation" = "Tester"
        "income" = 10000
    }
    "customFields" = @(
        @{
            "key" = "test_field"
            "value" = "test_value_$timestamp"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Testing client creation with unique data..." -ForegroundColor Cyan
Write-Host "Unique ID: $uniqueId" -ForegroundColor Yellow
Write-Host "Payload:" -ForegroundColor Gray
Write-Host $payload -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/clients/create" -Method POST -Body $payload -ContentType "application/json" -SkipHttpErrorCheck

    Write-Host "`nHTTP Status Code: $($response.StatusCode)" -ForegroundColor Yellow

    if ($response.StatusCode -eq 200) {
        Write-Host "`n✅ SUCCESS!" -ForegroundColor Green
        Write-Host "Response Content:" -ForegroundColor Green
        $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host
    } else {
        Write-Host "`n❌ ERROR Response:" -ForegroundColor Red
        Write-Host "Raw Response Content:" -ForegroundColor Red
        Write-Host $response.Content -ForegroundColor Gray
        
        try {
            $errorJson = $response.Content | ConvertFrom-Json
            Write-Host "`nFormatted Error Details:" -ForegroundColor Yellow
            $errorJson | ConvertTo-Json -Depth 10 | Write-Host
        } catch {
            Write-Host "Could not parse error response as JSON" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "`n❌ EXCEPTION: $($_.Exception.Message)" -ForegroundColor Red
}