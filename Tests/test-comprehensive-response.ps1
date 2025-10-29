$payload = @{
    addresses         = @(
        @{
            addressLine1 = "123 Main Street"
            addressType  = "PERMANENT"
            addressLine2 = "Apt 4B"
            addressLine3 = ""
            addressLine4 = ""
            email        = "john.doe@example.com"
            phone        = "+971501234567"
            city         = "Dubai"
            country      = "ARE"
            zip          = "12345"
            state        = "Dubai"
        }
    )
    contactDetails    = @{
        mobilePhone = "+971501234567"
        email       = "john.doe@example.com"
    }
    personalDetails   = @{
        firstName   = "John"
        lastName    = "Doe"
        dateOfBirth = "1990-05-15"
    }
    clientId          = "1234568"
    externalClientId  = "EXT-123456790"
    employmentDetails = @{
        employerName = "Tech Company Ltd"
        income       = 15000
        occupation   = "Software Engineer"
    }
    responseDetails   = $true  # Request comprehensive response
    customFields      = @(
        @{
            key   = "branch_code"
            value = "DXB001"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Testing client create with COMPREHENSIVE response..." -ForegroundColor Cyan
Write-Host "Response Details: $($payload.responseDetails)" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/clients/create" -Method POST -Body $payload -ContentType "application/json" -ErrorAction Stop
    Write-Host "`nSUCCESS: Client created with comprehensive response!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10 | Write-Host
}
catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    
    # Use Invoke-WebRequest instead to get better error details
    try {
        $webResponse = Invoke-WebRequest -Uri "http://localhost:3000/client/create" -Method POST -Body $payload -ContentType "application/json" -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            $statusDescription = $_.Exception.Response.StatusDescription
            Write-Host "HTTP Status: $statusCode - $statusDescription" -ForegroundColor Yellow

            # Read the error response content using Invoke-WebRequest
            try {
                $errorResponse = Invoke-WebRequest -Uri "http://localhost:3000/clients/create" -Method POST -Body $payload -ContentType "application/json" -SkipHttpErrorCheck
                Write-Host "Detailed Error Response:" -ForegroundColor Red
                Write-Host $errorResponse.Content -ForegroundColor Gray
            } catch {
                Write-Host "Could not read detailed error response" -ForegroundColor Red
            }
        } else {
            Write-Host "No HTTP response available" -ForegroundColor Red
        }
    }
}