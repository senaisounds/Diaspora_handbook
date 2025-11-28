import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:diaspora_handbook/models/event.dart';
import 'package:diaspora_handbook/screens/favorites_screen.dart';
import 'package:diaspora_handbook/providers/favorites_provider.dart';
import 'package:diaspora_handbook/providers/events_provider.dart';
import 'package:diaspora_handbook/providers/reminders_provider.dart';
import 'package:diaspora_handbook/providers/registration_provider.dart';
import '../helpers/test_data.dart';

class MockEventsProvider extends Mock implements EventsProvider {
  @override
  List<Event> get events => TestData.allEvents;
}

class MockFavoritesProvider extends Mock implements FavoritesProvider {
  @override
  List<Event> get favoriteEvents => [];
}

class MockRemindersProvider extends Mock implements RemindersProvider {}
class MockRegistrationProvider extends Mock implements RegistrationProvider {}

void main() {
  late MockFavoritesProvider mockFavoritesProvider;
  late MockEventsProvider mockEventsProvider;
  late MockRemindersProvider mockRemindersProvider;
  late MockRegistrationProvider mockRegistrationProvider;

  setUp(() {
    mockFavoritesProvider = MockFavoritesProvider();
    mockEventsProvider = MockEventsProvider();
    mockRemindersProvider = MockRemindersProvider();
    mockRegistrationProvider = MockRegistrationProvider();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EventsProvider>.value(value: mockEventsProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: mockFavoritesProvider),
        ChangeNotifierProvider<RemindersProvider>.value(value: mockRemindersProvider),
        ChangeNotifierProvider<RegistrationProvider>.value(value: mockRegistrationProvider),
      ],
      child: const MaterialApp(
        home: FavoritesScreen(),
      ),
    );
  }

  testWidgets('FavoritesScreen displays tabs', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Saved Events'), findsOneWidget);
    expect(find.text('Handbook Guide'), findsOneWidget);
  });

  testWidgets('FavoritesScreen defaults to Saved Events tab', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Should see empty state for favorites
    expect(find.text('No events saved yet.'), findsOneWidget);
    
    // Should NOT see resources content yet
    expect(find.text('Emergency Contacts'), findsNothing);
  });

  testWidgets('Switching tabs shows Resources', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap Handbook Guide tab
    await tester.tap(find.text('Handbook Guide'));
    await tester.pumpAndSettle();

    // Should see resources content
    expect(find.text('Emergency Contacts'), findsOneWidget);
  });
}

