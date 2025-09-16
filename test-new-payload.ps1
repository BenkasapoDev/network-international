# Test the new payload structure with account, creditOptions, debitOptions

$payload = @{
    account = @{
        productCode = "stri"
        accountNumber = "0003254540000000396"
        externalAccountId = "00112211221122"
        profileCode = "001"
        branchCode = "982"
    }
    client = @{
        id = @{
            value = "string"
            type = "stringstring"
            additionalQualifiers = @(
                @{
                    value = "str"
                    type = "string"
                }
                @{
                    value = "string"
                    type = "string"
                }
            )
        }
    }
    creditOptions = @{
        creditLimitAmount = 20000
        billingDay = "1"
        directDebitNumber = "string"
    }
    debitOptions = @{
        accountType = "Credit"
    }
    responseDetails = $false
    customFields = @(
        @{
            key = "XXX"
            value = "XXX"
        }
        @{
            key = "XXX"
            value = "XXX"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Testing new payload structure..." -ForegroundColor Cyan
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