$payload = @{
    addresses = @(
        @{
            addressLine1 = "123 Main Street"
            addressType = "PERMANENT"
            addressLine2 = "Apt 4B"
            addressLine3 = ""
            addressLine4 = ""
            email = "john.doe@example.com"
            phone = "+971501234567"
            city = "Dubai"
            country = "ARE"
            zip = "12345"
            state = "Dubai"
        },
        @{
            addressLine1 = "456 Business Ave"
            addressType = "RESIDENT"
            addressLine2 = "Suite 100"
            addressLine3 = ""
            addressLine4 = ""
            email = "john.work@example.com"
            phone = "+971509876543"
            city = "Abu Dhabi"
            country = "ARE"
            zip = "54321"
            state = "Abu Dhabi"
        }
    )
    contactDetails = @{
        mobilePhone = "+971501234567"
        homePhone = "+97142345678"
        workPhone = "+97143456789"
        email = "john.doe@example.com"
    }
    personalDetails = @{
        firstName = "John"
        lastName = "Doe"
        gender = "M"
        title = "MR"
        middleName = "Michael"
        citizenship = "US"
        maritalStatus = "Single"
        dateOfBirth = "1990-05-15"
        placeOfBirth = "New York"
        language = "ENG"
        motherName = "Jane Doe"
    }
    embossingDetails = @{
        title = "MR"
        firstName = "JOHN"
        lastName = "DOE"
    }
    identityProofDocument = @{
        type = "national_id"
        number = "784199012345678"
        expiryDate = "2030-12-31"
    }
    clientId = "1234567"
    externalClientId = "EXT-123456789"
    supplementaryDocuments = @(
        @{
            number = "784199012345678"
            type = "national_id"
            expiryDate = "2030-12-31"
        },
        @{
            number = "A12345678"
            type = "passport"
            expiryDate = "2028-06-15"
        }
    )
    employmentDetails = @{
        employerName = "Tech Company Ltd"
        income = 15000
        occupation = "Software Engineer"
    }
    responseDetails = $false
    customFields = @(
        @{
            key = "branch_code"
            value = "DXB001"
        },
        @{
            key = "customer_segment"
            value = "PREMIUM"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Testing comprehensive client create..." -ForegroundColor Cyan
Write-Host "Payload:" -ForegroundColor Yellow
Write-Host $payload -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/client/create" -Method POST -Body $payload -ContentType "application/json" -ErrorAction Stop
    Write-Host "`nSUCCESS: Comprehensive client created!" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Yellow
    $response | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "`nERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}