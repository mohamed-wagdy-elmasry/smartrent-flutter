# All Vendors Dashboard Feature

## Overview
This feature allows users to browse and search cars from all vendors in the system with advanced filtering options.

## Features
- **Browse All Vendors**: View cars from all vendors in a single unified dashboard
- **Advanced Filters**: Filter cars by:
  - Car Type (SUV, Sedan, etc.)
  - Car Model
  - Year
- **No Date/Time Required**: Search for cars without selecting pickup date and time
- **Seamless Integration**: Works alongside the existing location-based dashboard

## Navigation
Users can access the All Vendors Dashboard from the main dashboard by clicking the **"Browse All Vendors Cars"** button at the top of the screen.

## File Structure

### Controller
- `lib/views/all_vendors_dashboard/controller/all_vendors_dashboard_controller.dart`
  - Manages state for filters (type, model, year)
  - Fetches all car types from API
  - Searches for cars based on selected filters
  - Handles car selection and navigation to booking

### Screens
- `lib/views/all_vendors_dashboard/screen/all_vendors_dashboard_screen.dart` - Main screen wrapper
- `lib/views/all_vendors_dashboard/screen/all_vendors_dashboard_mobile_screen.dart` - Mobile layout

### Widgets
- `lib/views/all_vendors_dashboard/widget/all_vendors_app_bar.dart` - Custom app bar with back button and refresh
- `lib/views/all_vendors_dashboard/widget/all_vendors_filter_box.dart` - Filter dropdowns (Type, Model, Year)
- `lib/views/all_vendors_dashboard/widget/all_vendors_search_button.dart` - Search button
- `lib/views/all_vendors_dashboard/widget/all_vendors_car_carousel.dart` - Car carousel display with booking

### Binding
- `lib/bindings/all_vendors_dashboard_binding.dart` - Dependency injection for controller

### Routes
- Route name: `Routes.allVendorsDashboardScreen`
- Path: `/allVendorsDashboardScreen`

## API Endpoints Used

### Get All Types
- **Endpoint**: `/user/car-booking/type`
- **Method**: GET
- **Description**: Fetches all available car types across all vendors

### Get Models by Type
- **Endpoint**: `/user/car-booking/type/models`
- **Method**: POST
- **Body**: `{ "type": <car_type_id> }`
- **Description**: Fetches car models for selected type

### Get Years by Model
- **Endpoint**: `/user/car-booking/model/years`
- **Method**: POST
- **Body**: `{ "type": <car_type_id>, "model": <model_id> }`
- **Description**: Fetches available years for selected model

### Search Cars
- **Endpoint**: `/user/car-booking/search/car`
- **Method**: POST
- **Body**: 
  ```json
  {
    "car_type": <car_type_id>,     // Optional
    "car_model": <car_model_id>,   // Optional
    "car_year": <year>             // Optional
  }
  ```
- **Description**: Searches for cars matching the selected filters

## Usage Flow

1. User navigates from main dashboard → "Browse All Vendors Cars"
2. User selects filters (Type, Model, Year) - all optional
3. User clicks "Search Cars"
4. System displays matching cars in a carousel
5. User can:
   - Tap on a car image to view details and book
   - Use "Book Now" button to proceed with booking
   - Refresh filters and search again

## Integration with Booking

When a car is selected from the All Vendors Dashboard:
1. Car ID and token are stored in the main `DashboardController`
2. User is navigated to the standard booking screen
3. Booking process continues normally using the selected car information

## Key Differences from Main Dashboard

| Feature | Main Dashboard | All Vendors Dashboard |
|---------|---------------|----------------------|
| Scope | Location-based (specific area) | All vendors system-wide |
| Required Filters | Area, Date, Time | None (all optional) |
| Car Source | Cars in selected area | All cars in system |
| Use Case | Specific location/time booking | Browse and compare all options |

## Future Enhancements
- Add pagination for large result sets
- Include price range filter
- Add sorting options (price, year, rating)
- Show vendor information on car cards
- Add favorite/save functionality
- Map view showing car locations
