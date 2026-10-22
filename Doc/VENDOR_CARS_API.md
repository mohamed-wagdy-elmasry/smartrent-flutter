# Vendor Cars API - Implementation Summary

## Overview

This document summarizes the implementation of the vendor cars listing API endpoint for the car rental mobile application.

## Endpoint Details

### Get All Vendor Cars

-   **URL**: `/api/v1/vendor/cars`
-   **Method**: `GET`
-   **Authentication**: Not required (public endpoint)
-   **Description**: Retrieves a paginated list of all approved and active vendor cars with comprehensive filtering and sorting capabilities.

## Query Parameters

| Parameter        | Type    | Required | Description                                                        | Example        |
| ---------------- | ------- | -------- | ------------------------------------------------------------------ | -------------- |
| `page`           | integer | No       | Page number for pagination (default: 1)                            | `1`            |
| `per_page`       | integer | No       | Items per page (default: 15, max: 50)                              | `20`           |
| `type`           | string  | No       | Car type filter (economy, suv, luxury, family, sedan, sports, van) | `suv`          |
| `model`          | string  | No       | Car model name (partial match supported)                           | `Toyota Camry` |
| `price_min`      | decimal | No       | Minimum price per day                                              | `50.00`        |
| `price_max`      | decimal | No       | Maximum price per day                                              | `200.00`       |
| `rating_min`     | decimal | No       | Minimum average rating (0-5)                                       | `4.0`          |
| `year_min`       | integer | No       | Minimum model year                                                 | `2020`         |
| `year_max`       | integer | No       | Maximum model year                                                 | `2024`         |
| `available_from` | date    | No       | Start date for availability check (YYYY-MM-DD)                     | `2025-11-15`   |
| `available_to`   | date    | No       | End date for availability check (YYYY-MM-DD)                       | `2025-11-20`   |
| `sort_by`        | string  | No       | Sorting option                                                     | `price_asc`    |
| `vendor_id`      | integer | No       | Filter by specific vendor ID                                       | `123`          |
| `seats_min`      | integer | No       | Minimum number of seats                                            | `5`            |

## Sorting Options

-   **`price_asc`**: Price low to high
-   **`price_desc`**: Price high to low
-   **`rating_desc`**: Rating high to low (placeholder - needs rating system)
-   **`year_desc`**: Newest first (by model year)
-   **`recommended`** (default): Multi-factor algorithm:
    -   Newer cars preferred (year desc)
    -   Lower prices preferred (better value)
    -   More seats preferred (more practical)

## Example Requests

### 1. Basic Request - Get All Cars

```bash
GET /api/v1/vendor/cars
```

### 2. Filter by Type and Price

```bash
GET /api/v1/vendor/cars?type=suv&price_max=150&sort_by=price_asc
```

### 3. Check Availability for Date Range

```bash
GET /api/v1/vendor/cars?available_from=2025-11-15&available_to=2025-11-20&rating_min=4.0
```

### 4. Advanced Filtering

```bash
GET /api/v1/vendor/cars?type=luxury&year_min=2022&seats_min=5&sort_by=year_desc&per_page=10
```

### 5. Search by Model

```bash
GET /api/v1/vendor/cars?model=camry&sort_by=price_asc
```

## Response Structure

```json
{
    "success": true,
    "message": ["Vendor cars retrieved successfully"],
    "data": {
        "cars": [
            {
                "id": 1,
                "vendor_id": 89,
                "vendor_name": "Premium Car Rentals",
                "vendor_rating": 4.5,
                "make": "Sedan",
                "model": "Toyota Camry",
                "type": "sedan",
                "year": 2024,
                "color": "Not specified",
                "license_plate": "ABC-1234",
                "transmission": "automatic",
                "fuel_type": "petrol",
                "seats": 5,
                "doors": 4,
                "price_per_day": 120.0,
                "currency": "USD",
                "rating": 4.5,
                "total_reviews": 0,
                "availability_status": "available",
                "next_available_date": null,
                "images": [
                    {
                        "id": 1,
                        "url": "https://example.com/storage/cars/image.jpg",
                        "is_primary": true
                    }
                ],
                "features": [],
                "insurance_included": true,
                "mileage_limit_per_day": 200,
                "mileage_unit": "km",
                "deposit_required": 100.0,
                "cancellation_policy": "free_24h",
                "vendor_location": {
                    "city": "Dubai",
                    "address": "Sheikh Zayed Road",
                    "latitude": null,
                    "longitude": null
                }
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 15,
            "total": 156,
            "total_pages": 11,
            "from": 1,
            "to": 15,
            "has_more": true
        },
        "filters_applied": {
            "type": "suv",
            "price_max": "150"
        },
        "meta": {
            "available_types": ["economy", "sedan", "suv", "luxury"],
            "price_range": {
                "min": 35.0,
                "max": 850.0
            },
            "year_range": {
                "min": 2018,
                "max": 2024
            }
        }
    },
    "timestamp": "2025-11-09T14:32:15Z"
}
```

## Error Responses

### Validation Error (422)

```json
{
    "success": false,
    "message": {
        "error": [
            "The price min must be at least 0.",
            "The available to must be a date after or equal to available from."
        ]
    }
}
```

## Implementation Files

### 1. Controller

-   **Path**: `app/Http/Controllers/Api/V1/VendorCarController.php`
-   **Description**: Main controller handling filtering, sorting, and response formatting

### 2. Route

-   **Path**: `routes/api/v1/global.php`
-   **Route**: `GET /api/v1/vendor/cars`

### 3. Translations

Updated in all language files:

-   `lang/en.json`: "Vendor cars retrieved successfully"
-   `lang/ar.json`: "تم استرجاع سيارات البائعين بنجاح"
-   `lang/es.json`: "Vehículos de proveedores recuperados exitosamente"
-   `lang/fr.json`: "Véhicules des fournisseurs récupérés avec succès"

## Database Queries

The implementation uses efficient queries with:

-   Eager loading of relationships (vendor, type, model, area, branch)
-   Proper indexing assumptions on filterable fields
-   Availability check through booking conflicts detection
-   Pagination for performance

## Features

✅ Comprehensive filtering (type, model, price, year, availability, seats)
✅ Multiple sorting options
✅ Pagination with metadata
✅ Availability checking based on booking conflicts
✅ Multi-language support
✅ Vendor information included
✅ Meta information for dynamic filter UI
✅ Validation of all query parameters

## Future Enhancements

The following fields are placeholders for future implementation:

1. **Rating System**

    - Add car reviews and ratings table
    - Calculate average rating from bookings
    - Implement rating-based sorting

2. **Additional Car Properties**

    - `color`: Add color column to cars table
    - `transmission`: Add transmission type column
    - `fuel_type`: Add fuel type column
    - `doors`: Add doors count column
    - `features`: Create car_features relation table

3. **Enhanced Location**

    - Add latitude/longitude to vendor_branches
    - Implement distance-based filtering
    - Add map integration support

4. **Performance Optimization**
    - Add caching layer for common queries
    - Implement search indexes
    - Add Redis caching for meta information

## Testing

Test the endpoint using:

```bash
# Using curl
curl -X GET "http://your-domain/api/v1/vendor/cars?type=suv&price_max=150&sort_by=price_asc"

# Using Postman or any API client
GET http://your-domain/api/v1/vendor/cars
```

## Notes

-   All cars returned are already filtered to only show approved (`approval = 1`) and active (`status = 1`) vehicles
-   Availability checking prevents overlapping bookings
-   The endpoint is public (no authentication required) to support mobile app browsing
-   Pagination prevents performance issues with large datasets
-   Meta information helps mobile apps build dynamic filter UIs

---

**Implementation Date**: November 9, 2025
**Version**: 1.0
**Status**: ✅ Complete and Ready for Testing
