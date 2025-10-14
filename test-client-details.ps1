# Test Client Details Endpoint
Write-Host "Testing client details endpoint..." -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Test payload for client details
$payload = @{
    "client" = @{
        "id" = @{
            "value" = "11232123"
            "type" = "clientId"
            "additionalQualifiers" = @{
                "type" = "mbr"
                "value" = "0"
            }
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "Payload:" -ForegroundColor Gray
Write-Host $payload -ForegroundColor Gray
Write-Host ""

# Test the endpoint
try {
    Write-Host "Making request to /clients/details..." -ForegroundColor Yellow
    $response = Invoke-WebRequest -Uri "$baseUrl/clients/details" -Method POST -Body $payload -ContentType "application/json" -SkipHttpErrorCheck

    Write-Host "HTTP Status Code: $($response.StatusCode)" -ForegroundColor Yellow
    Write-Host "Response Headers:" -ForegroundColor Yellow
    $response.Headers | Format-Table -AutoSize

    if ($response.StatusCode -eq 200) {
        Write-Host "`n✅ SUCCESS!" -ForegroundColor Green
        Write-Host "Response Content:" -ForegroundColor Green
        $response.Content | ConvertTo-Json -Depth 10 | Write-Host
    } else {
        Write-Host "`n❌ ERROR Response:" -ForegroundColor Red
        Write-Host "Raw Response Content:" -ForegroundColor Red
        Write-Host $response.Content -ForegroundColor Gray

        # Try to parse as JSON for better formatting
        try {
            $errorJson = $response.Content | ConvertFrom-Json
            Write-Host "`nFormatted Error Details:" -ForegroundColor Yellow
            $errorJson | ConvertTo-Json -Depth 10 | Write-Host

            # Check if details object exists and is populated
            if ($errorJson.details) {
                Write-Host "`nDetails object found:" -ForegroundColor Cyan
                $errorJson.details | ConvertTo-Json -Depth 10 | Write-Host
            } else {
                Write-Host "`n❌ No details object found in error response!" -ForegroundColor Red
            }
        } catch {
            Write-Host "Could not parse error response as JSON" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "`n❌ EXCEPTION: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Exception Details:" -ForegroundColor Yellow
    $_.Exception | Format-List -Force
}