# Test Quick Reference

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/controllers/booking_controller_test.dart

# Run integration tests
flutter test integration_test/book_car_test.dart

# Run tests in watch mode (using entr or similar)
find test -name "*.dart" | entr -c flutter test

# Generate coverage HTML
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

## Test File Locations

```
test/
├── controllers/
│   ├── booking_controller_test.dart      # 24 unit tests
│   └── preview_controller_test.dart      # 18 unit tests
└── widgets/
    └── booking_screen_test.dart          # 21 widget tests

integration_test/
└── book_car_test.dart                    # 10 integration tests
```

## Quick Test Examples

### Run Single Test Group
```dart
flutter test test/controllers/booking_controller_test.dart --name "Form Validation"
```

### Run Single Test Case
```dart
flutter test test/controllers/booking_controller_test.dart --name "form is invalid when quantity is empty"
```

### Debug Mode
```bash
flutter test --verbose test/controllers/booking_controller_test.dart
```

## Coverage Goals

| Component | Target |
|-----------|--------|
| Controllers | >90% |
| Widgets | >80% |
| Overall | >80% |

## Test Status

| Test Suite | Tests | Status |
|------------|-------|--------|
| BookingController | 24 | ✅ |
| PreviewController | 18 | ✅ |
| Booking Screen | 21 | ✅ |
| Integration | 10 | ✅ |

## Critical Test Scenarios

### ✅ Must Pass Before Deploy

1. **Complete booking flow** - Integration test
2. **Form validation** - Unit tests
3. **Date/time validation** - Unit tests
4. **Delivery validation** - Unit tests
5. **Payment flow** - Integration test

### ⚠️ Known Issues

- API mocking not implemented (tests use mock data)
- Some integration tests require connected device/emulator

## Debugging Tests

```bash
# Run with print statements visible
flutter test --verbose

# Run single test for debugging
flutter test test/path/to/test.dart --name "specific test name"

# Use debugger in VS Code
# 1. Set breakpoint in test
# 2. Run > Start Debugging
```

## Before Committing

```bash
# Run all tests
flutter test

# Check coverage
flutter test --coverage

# Verify no skipped tests
grep -r "skip: true" test/
```

## Help

- Full docs: `test/README.md`
- Execution guide: `test/TEST_EXECUTION_GUIDE.md`
- Summary: `Doc/integration-tests-summary.md`
