$payload = @{
    body = @{
        customer_id = "test-client-001"
        first_name = "John"
        last_name = "Doe"
        email = "john.doe@example.com"
        phone = "+1234567890"
        accounts = @(
            @{
                account_identifier = "ACC-001"
                currency = "USD"
                status = "active"
            }
        )
        cards = @(
            @{
                external_card_id = "CARD-001"
                masked_card_number = "****1234"
                product_code = "VISA"
                status = "active"
            }
        )
    }
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/client/create" -Method POST -Body $payload -ContentType "application/json" -ErrorAction Stop
    Write-Host "SUCCESS: Client created!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10 | Write-Host
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}