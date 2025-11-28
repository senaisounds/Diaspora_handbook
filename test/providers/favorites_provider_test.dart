import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/providers/favorites_provider.dart';
import 'package:diaspora_handbook/providers/events_provider.dart';
import '../helpers/test_data.dart';

void main() {
  late FavoritesProvider favoritesProvider;
  late EventsProvider eventsProvider;

  setUp(() {
    eventsProvider = EventsProvider();
    eventsProvider.setEvents(TestData.allEvents);
    favoritesProvider = FavoritesProvider(eventsProvider);
  });

  group('FavoritesProvider Tests', () {
    test('should start with no favorites', () {
      expect(favoritesProvider.favoriteEvents, isEmpty);
    });

    test('should add event to favorites', () async {
      // Act
      await favoritesProvider.toggleFavorite('event1');

      // Assert
      expect(favoritesProvider.isFavorite('event1'), isTrue);
      expect(favoritesProvider.favoriteEvents.length, 1);
      expect(favoritesProvider.favoriteEvents.first.id, 'event1');
    });

    test('should remove event from favorites', () async {
      // Arrange
      await favoritesProvider.toggleFavorite('event1');

      // Act
      await favoritesProvider.toggleFavorite('event1');

      // Assert
      expect(favoritesProvider.isFavorite('event1'), isFalse);
      expect(favoritesProvider.favoriteEvents, isEmpty);
    });

    test('should handle multiple favorites', () async {
      // Act
      await favoritesProvider.toggleFavorite('event1');
      await favoritesProvider.toggleFavorite('event2');
      await favoritesProvider.toggleFavorite('event3');

      // Assert
      expect(favoritesProvider.favoriteEvents.length, 3);
    });

    test('should clear all favorites', () async {
      // Arrange
      await favoritesProvider.toggleFavorite('event1');
      await favoritesProvider.toggleFavorite('event2');

      // Act
      await favoritesProvider.clearAllFavorites();

      // Assert
      expect(favoritesProvider.favoriteEvents, isEmpty);
    });
  });
}

