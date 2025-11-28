# Testing Guide for Diaspora Handbook

Comprehensive testing documentation for the Diaspora Handbook Flutter app.

## 📋 Table of Contents
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Test Types](#test-types)
- [Writing Tests](#writing-tests)

## 🗂️ Test Structure

```
test/
├── helpers/
│   └── test_data.dart          # Test data fixtures
├── mocks/
│   ├── mock_providers.dart     # Mock providers
│   └── mock_services.dart      # Mock services
├── models/
│   ├── event_test.dart         # Event model tests
│   ├── channel_test.dart       # Channel model tests
│   └── message_test.dart       # Message model tests
├── providers/
│   ├── events_provider_test.dart
│   ├── favorites_provider_test.dart
│   ├── search_provider_test.dart
│   └── chat_provider_test.dart
├── services/
│   └── api_service_test.dart
├── widgets/
│   └── event_card_test.dart
├── screens/
│   └── channels_screen_test.dart
└── integration/
    └── app_flow_test.dart
```

## 🏃 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/providers/events_provider_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Integration Tests
```bash
flutter test integration_test/app_flow_test.dart
```

## 📊 Test Coverage

### Current Coverage

#### Providers (100%)
- ✅ EventsProvider - Event loading, filtering
- ✅ FavoritesProvider - Add/remove favorites
- ✅ SearchProvider - Search and filters
- ✅ ChatProvider - Channels and messages

#### Models (100%)
- ✅ Event - Serialization, validation
- ✅ Channel - CRUD operations
- ✅ Message - Message handling
- ✅ ChatUser - User management

#### Services
- ✅ ApiService - Basic tests
- ⏳ NotificationService - Pending
- ⏳ AdService - Pending

#### Widgets
- ✅ EventCard - Display and interactions
- ⏳ CountdownWidget - Pending
- ⏳ StatisticsWidget - Pending

#### Screens
- ✅ ChannelsScreen - Channel list display
- ⏳ HomeScreen - Pending
- ⏳ ChatScreen - Pending

## 🧪 Test Types

### 1. Unit Tests
Test individual functions and classes in isolation.

**Location:** `test/providers/`, `test/models/`, `test/services/`

**Example:**
```dart
test('should add event to favorites', () async {
  // Arrange
  final provider = FavoritesProvider(eventsProvider);
  
  // Act
  await provider.toggleFavorite('event1');
  
  // Assert
  expect(provider.isFavorite('event1'), isTrue);
});
```

### 2. Widget Tests
Test UI components and their interactions.

**Location:** `test/widgets/`, `test/screens/`

**Example:**
```dart
testWidgets('should display event information', (WidgetTester tester) async {
  await tester.pumpWidget(
    createTestWidget(EventCard(event: testEvent)),
  );
  
  expect(find.text('Test Event'), findsOneWidget);
});
```

### 3. Integration Tests
Test complete user flows and feature interactions.

**Location:** `test/integration/`

**Example:**
```dart
testWidgets('should navigate through main screens', (WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle();
  
  await tester.tap(find.text('Schedule'));
  await tester.pumpAndSettle();
  
  expect(find.byIcon(Icons.calendar_month), findsWidgets);
});
```

## ✍️ Writing Tests

### Setting Up Tests

1. **Create Test File**
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mockito/mockito.dart';
   
   void main() {
     group('Feature Tests', () {
       setUp(() {
         // Setup code before each test
       });
       
       tearDown(() {
         // Cleanup after each test
       });
     });
   }
   ```

2. **Use Test Data**
   ```dart
   import '../helpers/test_data.dart';
   
   test('should use test event', () {
     final event = TestData.event1;
     expect(event.title, 'Test Event 1');
   });
   ```

3. **Mock Dependencies**
   ```dart
   import '../mocks/mock_services.dart';
   
   final mockApiService = MockApiService();
   when(mockApiService.getEvents())
       .thenAnswer((_) async => TestData.allEvents);
   ```

### Test Organization

```dart
void main() {
  group('ProviderName Tests', () {
    late ProviderName provider;
    late MockDependency mockDependency;
    
    setUp(() {
      mockDependency = MockDependency();
      provider = ProviderName(mockDependency);
    });
    
    group('Method Group', () {
      test('should do something', () {
        // Test code
      });
      
      test('should handle errors', () {
        // Test code
      });
    });
  });
}
```

### Widget Test Helpers

```dart
Widget createTestWidget(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<Provider1>.value(value: provider1),
      ChangeNotifierProvider<Provider2>.value(value: provider2),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}
```

## 🎯 Best Practices

### 1. Test Naming
- Use descriptive names: `should_do_something_when_condition`
- Group related tests
- Be specific about what you're testing

### 2. AAA Pattern
```dart
test('description', () {
  // Arrange - Set up test data
  final input = 'test';
  
  // Act - Execute the code
  final result = function(input);
  
  // Assert - Verify results
  expect(result, 'expected');
});
```

### 3. Test Independence
- Each test should be independent
- Don't rely on test order
- Use setUp/tearDown for common code

### 4. Meaningful Assertions
```dart
// Good
expect(events.length, 3);
expect(events.first.title, 'Expected Title');

// Avoid
expect(true, isTrue);
```

## 🐛 Debugging Tests

### Print Statements
```dart
test('debug test', () {
  print('Variable value: $value');
  debugPrint('Debug info: $info');
});
```

### Run Single Test
```bash
flutter test --plain-name "test name"
```

### Verbose Output
```bash
flutter test --verbose
```

## 📈 Continuous Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## 🔄 Test-Driven Development (TDD)

1. **Write a failing test**
   ```dart
   test('should calculate total', () {
     expect(calculator.add(2, 2), 4);
   });
   ```

2. **Write minimum code to pass**
   ```dart
   int add(int a, int b) => a + b;
   ```

3. **Refactor**
   - Improve code quality
   - Keep tests passing

## 📚 Additional Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing Guide](https://flutter.dev/docs/testing/integration-tests)

## 🚀 Future Improvements

- [ ] Increase widget test coverage to 80%+
- [ ] Add performance tests
- [ ] Implement visual regression testing
- [ ] Add E2E tests with real backend
- [ ] Set up automated CI/CD pipeline
- [ ] Add golden file testing for widgets

---

**Last Updated:** 2025-01-25

For questions or issues, please check the main README or create an issue.

