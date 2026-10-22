# Test Execution Guide - Book Car Integration Tests

## Prerequisites

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Verify Flutter Doctor
```bash
flutter doctor
```

## Quick Start

### Run All Tests
```bash
# Run all unit tests
flutter test

# Run all tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/book_car_test.dart
```

### Run Specific Test Suites

#### BookingController Tests
```bash
flutter test test/controllers/booking_controller_test.dart
```

#### PreviewController Tests
```bash
flutter test test/controllers/preview_controller_test.dart
```

#### Widget Tests
```bash
flutter test test/widgets/booking_screen_test.dart
```

#### Integration Tests (Full Flow)
```bash
flutter test integration_test/book_car_test.dart
```

## Test Execution on Devices

### Android Device/Emulator
```bash
# Start emulator
emulator -avd Pixel_8_API_34

# Run integration tests on device
flutter test integration_test/book_car_test.dart --device-id <device_id>
```

### iOS Simulator
```bash
# List simulators
xcrun simctl list

# Boot simulator
open -a Simulator

# Run tests
flutter test integration_test/book_car_test.dart --device-id <simulator_id>
```

## Coverage Report

### Generate Coverage
```bash
flutter test --coverage
```

### View Coverage in HTML
```bash
# Install genhtml (macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html
```

### View Coverage in VS Code
1. Install extension: **Coverage Gutters**
2. Run tests with coverage
3. Click **Watch** in status bar

## Continuous Integration

### GitHub Actions Example
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
```

## Test Scenarios Covered

### ✅ Unit Tests

**BookingController (24 tests)**
- Car initialization and pricing setup
- Form validation (required fields, date/time)
- Delivery availability and zone validation
- Booking data preparation
- Missing fields detection

**PreviewController (18 tests)**
- Initialization with booking data
- Payment method selection
- Booking data validation
- Moyasar payment data preparation
- Wallet payment validation
- Error handling

**Widget Tests (21 tests)**
- UI component rendering
- Form interaction
- Dynamic label updates
- Loading states
- Date/time picker integration

### ✅ Integration Tests (10 scenarios)

1. **Complete booking flow - per day pricing**
   - Select car → fill form → navigate to preview → confirm booking

2. **Booking with delivery option**
   - Enable delivery → set location → calculate delivery charge

3. **Form validation - missing fields**
   - Verify all required fields are validated

4. **Form validation - past date/time**
   - Reject past pickup dates and times

5. **Price estimation - different rental periods**
   - Test daily/weekly/monthly pricing tiers

6. **Per km pricing flow**
   - Complete flow with per_km pricing type

7. **Delivery validation - out of zone**
   - Block checkout when delivery is unavailable

8. **Wallet payment flow**
   - Complete booking with wallet payment

9. **Booking data preparation**
   - Verify all fields are included correctly

10. **Booking data with delivery**
    - Verify delivery fields are included when enabled

## Debugging Tests

### Enable Verbose Logging
```bash
flutter test --verbose test/controllers/booking_controller_test.dart
```

### Run Single Test
```dart
test('description', () {
  // Test code
}, skip: false); // Remove skip to run only this test
```

### Debug in VS Code
1. Set breakpoint in test file
2. Run → Start Debugging
3. Select **Dart & Flutter** configuration

### Debug in Android Studio
1. Right-click test file
2. Select **Debug 'booking_controller_test.dart'**
3. Use debugger to step through

## Common Issues & Solutions

### Issue: GetX Controller Not Found
```
Error: Controller 'BookingController' is not registered
```

**Solution:**
```dart
setUp(() {
  Get.testMode = true;
  Get.put(BookingController());
});

tearDown(() {
  Get.reset();
});
```

### Issue: LocalStorage Not Initialized
```
Error: LocalStorage.init() must be called before accessing
```

**Solution:**
```dart
setUp(() async {
  await LocalStorage.init();
  LocalStorage.email = 'test@example.com';
});
```

### Issue: Async Test Timeout
```
Error: Test timed out after 30 seconds
```

**Solution:**
```dart
testWidgets('test name', (WidgetTester tester) async {
  await tester.pumpWidget(...);
  await tester.pumpAndSettle(); // Wait for all animations
  
  // Perform actions
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle(); // Wait again
}, timeout: const Timeout(Duration(seconds: 60)));
```

### Issue: Widget Not Found
```
Error: Expected: exactly one matching node
Actual: _WidgetTypeFinder:<zero widgets>
```

**Solution:**
```dart
// Ensure widget is built and visible
await tester.pumpAndSettle();

// Use more specific finder
final widget = find.byKey(const Key('specific_key'));
expect(widget, findsOneWidget);

// Debug what widgets exist
debugDumpApp(); // In test
```

### Issue: Golden File Mismatch
```
Error: Golden file does not match
```

**Solution:**
```bash
# Update golden files
flutter test --update-goldens
```

## Performance Testing

### Measure Test Execution Time
```bash
time flutter test test/controllers/booking_controller_test.dart
```

### Profile Integration Tests
```bash
flutter run --profile integration_test/book_car_test.dart
```

## Test Data Setup

### Mock Car Data
Located in each test file as `_createMockCar()` helper function.

**Example:**
```dart
VendorCar _createMockCar({
  String pricingType = 'per_day',
  double price = 100.0,
  bool isDeliveryAvailable = false,
}) {
  return VendorCar(
    id: 1,
    make: 'Toyota',
    model: 'Camry',
    pricing: Pricing(
      price: price,
      type: pricingType,
      currency: 'SAR',
    ),
    // ... other fields
  );
}
```

### Mock API Responses
For integration tests that require API mocking:

```dart
// TODO: Implement API mocking with mockito
// Example:
when(mockApiClient.post(any, body: anyNamed('body')))
    .thenAnswer((_) async => Response(mockJson, 200));
```

## Next Steps

### 1. Add API Mocking
- [ ] Create mock API client
- [ ] Mock price estimation endpoint
- [ ] Mock booking confirmation endpoint
- [ ] Mock wallet balance endpoint

### 2. Add More Edge Cases
- [ ] Network error handling
- [ ] Invalid API responses
- [ ] Concurrent booking attempts
- [ ] Session timeout scenarios

### 3. Performance Tests
- [ ] Large car list rendering
- [ ] Price calculation performance
- [ ] Form validation performance

### 4. Accessibility Tests
- [ ] Screen reader support
- [ ] Keyboard navigation
- [ ] Color contrast
- [ ] Font scaling

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [GetX Testing Guide](https://github.com/jonataslaw/getx#testing)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Flutter Test Best Practices](https://docs.flutter.dev/cookbook/testing)

## Support

For issues or questions about tests:
1. Check this guide
2. Review test code comments
3. Check Flutter/GetX documentation
4. Ask team in development channel
