# Simple debug test for client creation endpoint

$payload = @{
    "clientId" = "test123"
    "externalClientId" = "EXT-test123"
    "responseDetails" = $false
    "personalDetails" = @{
        "firstName" = "Test"
        "lastName" = "User"
        "dateOfBirth" = "1990-01-01"
    }
} | ConvertTo-Json -Depth 10

Write-Host "Testing client creation with debug details..." -ForegroundColor Cyan
Write-Host "Payload:" -ForegroundColor Gray
Write-Host $payload -ForegroundColor Gray

# Use Invoke-WebRequest with SkipHttpErrorCheck to capture full response
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/clients/create" -Method POST -Body $payload -ContentType "application/json" -SkipHttpErrorCheck

    Write-Host "`nHTTP Status Code: $($response.StatusCode)" -ForegroundColor Yellow
    Write-Host "Response Headers:" -ForegroundColor Yellow
    $response.Headers | Format-Table -AutoSize

    if ($response.StatusCode -eq 200) {
        Write-Host "`n✅ SUCCESS!" -ForegroundColor Green
        Write-Host "Response Content:" -ForegroundColor Green
        $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host
    } else {
        Write-Host "`n❌ ERROR Response:" -ForegroundColor Red
        Write-Host "Raw Response Content:" -ForegroundColor Red
        Write-Host $response.Content -ForegroundColor Gray
        
        # Try to parse as JSON for better formatting
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
    Write-Host "Exception Details:" -ForegroundColor Yellow
    $_.Exception | Format-List -Force
}