# Carbo App - Book Car Tests

This directory contains comprehensive tests for the car booking functionality in the Carbo rental app.

## Test Structure

```
test/
├── controllers/
│   ├── booking_controller_test.dart     # Unit tests for BookingController
│   └── preview_controller_test.dart      # Unit tests for PreviewController
└── widgets/
    └── booking_screen_test.dart          # Widget tests for booking UI

integration_test/
└── book_car_test.dart                    # End-to-end integration tests
```

## Running Tests

### Run all unit tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/controllers/booking_controller_test.dart
```

### Run integration tests
```bash
flutter test integration_test/book_car_test.dart
```

### Run with coverage
```bash
flutter test --coverage
```

## Test Coverage

### BookingController Tests (`test/controllers/booking_controller_test.dart`)

**Car Initialization**
- ✅ Initializes car and pricing correctly
- ✅ Normalizes pricing type ('daily' → 'per_day', 'km' → 'per_km')

**Form Validation**
- ✅ Validates required fields (quantity, date, time)
- ✅ Validates pickup date/time is in the future
- ✅ Validates delivery location when delivery enabled
- ✅ Blocks checkout when delivery is out of zone
- ✅ Handles delivery toggle state

**Date/Time Validation**
- ✅ Accepts future dates and times
- ✅ Rejects past dates
- ✅ Rejects today with past time
- ✅ Accepts today with future time
- ✅ Handles invalid date/time formats

**Quantity Labels**
- ✅ Returns correct label for per_day pricing ("Rental Days")
- ✅ Returns correct label for per_km pricing ("Distance")
- ✅ Returns correct hints based on pricing type

**Booking Data Preparation**
- ✅ Includes all required fields
- ✅ Includes delivery fields when enabled
- ✅ Excludes delivery fields when disabled
- ✅ Includes notes when provided
- ✅ Includes tax information

**Delivery Availability**
- ✅ Checks car delivery availability flag
- ✅ Checks vendor location coordinates
- ✅ Checks delivery zones (via dashboard controller)

**Missing Fields Detection**
- ✅ Returns all missing fields when form empty
- ✅ Returns empty when form complete
- ✅ Includes pickup location when delivery enabled
- ✅ Reports future date/time validation errors

### PreviewController Tests (`test/controllers/preview_controller_test.dart`)

**Initialization**
- ✅ Initializes with booking data from Get.arguments
- ✅ Falls back to BookingController when no arguments
- ✅ Sets online payment as default method
- ✅ Extracts car ID from booking data

**Payment Method Selection**
- ✅ Default payment method is online (wallet)
- ✅ Changes payment method correctly
- ✅ Returns payment type text

**Booking Data Validation**
- ✅ Validates car ID is not empty
- ✅ Validates pickup date is present
- ✅ Validates pickup time is present
- ✅ Accepts valid booking data

**Moyasar Payment Data**
- ✅ Prepares complete booking data for Moyasar
- ✅ Handles missing optional fields gracefully
- ✅ Uses fallback mobile number when empty

**Wallet Payment Validation**
- ✅ Validates booking token is present
- ✅ Validates total amount is present
- ✅ Checks wallet balance (integration with WalletController)

**Invoice Breakdown**
- ✅ Includes subtotal when provided
- ✅ Includes delivery charge when > 0
- ✅ Includes tax amount when > 0
- ✅ Includes discount amount
- ✅ Excludes zero values

**Error Handling**
- ✅ Handles null booking data
- ✅ Handles missing car_id
- ✅ Handles malformed total amount

**Delivery Data**
- ✅ Includes delivery fields when required
- ✅ Excludes delivery fields when not required

### Widget Tests (`test/widgets/booking_screen_test.dart`)

**UI Components**
- ✅ Displays quantity input field
- ✅ Displays delivery toggle (when available)
- ✅ Shows location picker when delivery enabled
- ✅ Displays price estimate
- ✅ Displays delivery charge
- ✅ Shows loading indicator during price estimation

**Form Interaction**
- ✅ Quantity field accepts numeric input
- ✅ Delivery toggle changes state
- ✅ Date picker opens on date field tap
- ✅ Time picker opens on time field tap

**Form State**
- ✅ Continue button disabled when form invalid
- ✅ Continue button enabled when form valid
- ✅ Validates form on field changes

**Data Display**
- ✅ Displays car information
- ✅ Displays pricing information
- ✅ Email field is pre-filled from LocalStorage
- ✅ Mobile field is pre-filled from LocalStorage
- ✅ Displays tax breakdown when enabled
- ✅ Shows pricing tier information
- ✅ Shows delivery distance when calculated

**Dynamic Labels**
- ✅ Quantity label changes based on pricing type

### Integration Tests (`integration_test/book_car_test.dart`)

**Complete Booking Flow**
- ✅ Full booking flow with per_day pricing
- ✅ Navigate from booking screen to preview to success
- ✅ Booking with delivery option enabled
- ✅ Per km pricing flow

**Form Validation Scenarios**
- ✅ Missing required fields
- ✅ Past pickup date/time validation
- ✅ Delivery validation - out of zone

**Payment Flows**
- ✅ Wallet payment flow
- ✅ Moyasar payment flow (mocked)

**Data Preparation**
- ✅ Booking data preparation with all fields
- ✅ Booking data with delivery fields
- ✅ Invoice breakdown fields

**Price Estimation**
- ✅ Different rental periods (daily/weekly/monthly tiers)
- ✅ Delivery charge calculation
- ✅ Tax calculation

## Mocking Strategy

### Local Storage
Tests initialize `LocalStorage` with mock data:
```dart
LocalStorage.email = 'test@example.com';
LocalStorage.number = '0501234567';
LocalStorage.token = 'test_token';
```

### API Calls
Integration tests should mock API calls using:
- `mockito` package for HTTP client mocking
- Test-specific endpoints that return mock data
- In-memory test database

### Controllers
Tests use `Get.testMode = true` and `Get.put()` to inject controllers.

## Adding New Tests

### Unit Test Template
```dart
test('description of what is being tested', () {
  // Arrange: Set up test data and controller state
  
  // Act: Perform the action being tested
  
  // Assert: Verify the expected outcome
  expect(actual, expected);
});
```

### Integration Test Template
```dart
testWidgets('complete flow description', (WidgetTester tester) async {
  // Start the app
  app.main();
  await tester.pumpAndSettle();
  
  // Navigate and interact
  Get.toNamed(Routes.bookingScreen, arguments: mockData);
  await tester.pumpAndSettle();
  
  // Interact with UI
  await tester.tap(find.byKey(const Key('button')));
  await tester.pumpAndSettle();
  
  // Verify outcome
  expect(Get.currentRoute, expectedRoute);
});
```

## Best Practices

1. **Isolate Tests**: Each test should be independent and not rely on other tests
2. **Clean Up**: Always dispose controllers and reset GetX in `tearDown()`
3. **Use Keys**: Add `Key` widgets to important UI elements for testing
4. **Mock External Dependencies**: Don't make real API calls in tests
5. **Test Edge Cases**: Include tests for error scenarios, empty data, and boundary conditions
6. **Descriptive Names**: Test names should clearly describe what is being tested
7. **Arrange-Act-Assert**: Follow this pattern for clear test structure

## Continuous Integration

Tests run automatically on:
- Pull requests
- Commits to main branch
- Pre-push hooks (if configured)

Minimum coverage requirement: **80%**

## Troubleshooting

### Common Issues

**GetX Controller Not Found**
```dart
// Solution: Register controller before accessing
Get.put(BookingController());
```

**LocalStorage Not Initialized**
```dart
// Solution: Initialize in setUp
await LocalStorage.init();
```

**Async Tests Timing Out**
```dart
// Solution: Add proper awaits
await tester.pumpAndSettle();
```

**Widget Not Found**
```dart
// Solution: Ensure widget is pumped before searching
await tester.pump();
expect(find.byKey(key), findsOneWidget);
```

## Contributing

When adding new booking features:
1. Write tests FIRST (TDD approach)
2. Ensure all tests pass before committing
3. Update this README with new test descriptions
4. Maintain >80% code coverage

## Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [GetX Testing](https://github.com/jonataslaw/getx/blob/master/documentation/en_US/state_management.md#testing)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
