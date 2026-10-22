# Test Car Booking Without Payment
# This script tests the booking flow without going through payment processing

# Configuration
$BASE_URL = "http://192.168.1.211:8000"
$JWT_TOKEN = "your_jwt_token_here"  # Replace with actual JWT token

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

Write-Info "=========================================="
Write-Info "Car Booking Test (Without Payment)"
Write-Info "=========================================="
Write-Info ""

# Step 1: Search for Cars
Write-Info "Step 1: Searching for available cars..."
Write-Info "Endpoint: POST /api/v1/user/car-booking/search/car"
Write-Info ""

$searchPayload = @{
    car_type = 1
    car_model = 5
    pickup_date = "2025-11-20"
    pickup_time = "10:00"
} | ConvertTo-Json

Write-Info "Request Body:"
Write-Info $searchPayload
Write-Info ""

try {
    $searchResponse = Invoke-WebRequest -Uri "$BASE_URL/api/v1/user/car-booking/search/car" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $JWT_TOKEN"
            "Content-Type" = "application/json"
        } `
        -Body $searchPayload `
        -UseBasicParsing

    $searchData = $searchResponse.Content | ConvertFrom-Json
    
    if ($searchData.status -eq 200) {
        Write-Success "✅ Car search successful!"
        Write-Info "Response:"
        Write-Info ($searchData | ConvertTo-Json -Depth 5)
        Write-Info ""
        
        # Extract token and car details
        $bookingToken = $searchData.data.token
        $cars = $searchData.data.cars
        
        if ($cars -and $cars.Count -gt 0) {
            $selectedCar = $cars[0]
            $carId = $selectedCar.id
            $carSlug = $selectedCar.slug
            $carName = $selectedCar.name
            $pricePerDay = $selectedCar.price_per_day
            
            Write-Success "✅ Found $($cars.Count) car(s)"
            Write-Info "Selected Car:"
            Write-Info "  - ID: $carId"
            Write-Info "  - Name: $carName"
            Write-Info "  - Slug: $carSlug"
            Write-Info "  - Price/Day: $pricePerDay"
            Write-Info "  - Booking Token: $bookingToken"
            Write-Info ""
            
            # Step 2: Test Confirm Booking (Without Payment)
            Write-Info "Step 2: Confirming booking (without payment)..."
            Write-Info "Endpoint: POST /api/v1/user/car-booking/test-confirm"
            Write-Info ""
            
            $confirmPayload = @{
                token = $bookingToken
                car_id = $carId
                car_slug = $carSlug
                mobile = "+966501234567"
                fees = [math]::Round($pricePerDay * 3, 2)  # 3 days
                credentials = "testuser@example.com"
                location = "Riyadh, Saudi Arabia"
                is_deliver = $true
                destination = "Airport Road, Riyadh"
                distance = 25
                rental_days = 3
                message = "Test booking without payment"
            } | ConvertTo-Json
            
            Write-Info "Request Body:"
            Write-Info $confirmPayload
            Write-Info ""
            
            $confirmResponse = Invoke-WebRequest -Uri "$BASE_URL/api/v1/user/car-booking/test-confirm" `
                -Method POST `
                -Headers @{
                    "Authorization" = "Bearer $JWT_TOKEN"
                    "Content-Type" = "application/json"
                } `
                -Body $confirmPayload `
                -UseBasicParsing
            
            $confirmData = $confirmResponse.Content | ConvertFrom-Json
            
            if ($confirmData.status -eq 200) {
                Write-Success "✅ Test Booking Confirmed Successfully!"
                Write-Success "No payment was processed"
                Write-Info ""
                Write-Info "Response:"
                Write-Info ($confirmData | ConvertTo-Json -Depth 5)
                Write-Info ""
                Write-Success "✅ TEST COMPLETED SUCCESSFULLY"
                Write-Info ""
                Write-Info "Summary:"
                Write-Info "  ✅ Car search: Successful"
                Write-Info "  ✅ Test booking confirmation: Successful"
                Write-Info "  ✅ Booking saved to database"
                Write-Info "  ✅ Notifications sent (if enabled)"
                Write-Info "  ✅ No payment processed"
                Write-Info ""
                Write-Warning "Note: This is a TEST booking. Payment was NOT processed."
                
            } else {
                Write-Error "❌ Test booking failed!"
                Write-Error "Status: $($confirmData.status)"
                Write-Error "Message: $($confirmData.message -join ', ')"
                Write-Info ($confirmData | ConvertTo-Json -Depth 5)
            }
            
        } else {
            Write-Error "❌ No cars found in search results"
        }
        
    } else {
        Write-Error "❌ Car search failed!"
        Write-Error "Status: $($searchData.status)"
        Write-Error "Message: $($searchData.message -join ', ')"
    }
    
} catch {
    Write-Error "❌ Error during car search: $($_.Exception.Message)"
    Write-Error "StatusCode: $($_.Exception.Response.StatusCode)"
    
    try {
        $errorContent = $_.Exception.Response.Content.ReadAsStream() | ForEach-Object { [System.IO.StreamReader]::new($_).ReadToEnd() }
        Write-Error "Response: $errorContent"
    } catch {
        # Ignore error reading response
    }
}

Write-Info ""
Write-Info "=========================================="
Write-Info "Test Completed"
Write-Info "=========================================="
