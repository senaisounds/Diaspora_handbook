import 'package:flutter_test/flutter_test.dart';
import 'package:diaspora_handbook/providers/search_provider.dart';

void main() {
  late SearchProvider searchProvider;

  setUp(() {
    searchProvider = SearchProvider();
  });

  group('SearchProvider Tests', () {
    test('should start with empty search history', () {
      expect(searchProvider.recentSearches, isEmpty);
    });

    test('should add search to history', () {
      // Act
      searchProvider.addToHistory('test search');

      // Assert
      expect(searchProvider.recentSearches, contains('test search'));
    });

    test('should not add duplicate searches to history', () {
      // Act
      searchProvider.addToHistory('test search');
      searchProvider.addToHistory('test search');

      // Assert
      expect(searchProvider.recentSearches.length, 1);
    });

    test('should remove search from history', () {
      // Arrange
      searchProvider.addToHistory('test search');

      // Act
      searchProvider.removeFromHistory('test search');

      // Assert
      expect(searchProvider.recentSearches, isEmpty);
    });

    test('should clear search history', () {
      // Arrange
      searchProvider.addToHistory('search 1');
      searchProvider.addToHistory('search 2');

      // Act
      searchProvider.clearHistory();

      // Assert
      expect(searchProvider.recentSearches, isEmpty);
    });

    test('should set date range', () {
      // Arrange
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 31);

      // Act
      searchProvider.setDateRange(start, end);

      // Assert
      expect(searchProvider.dateRangeStart, start);
      expect(searchProvider.dateRangeEnd, end);
    });

    test('should clear date range', () {
      // Arrange
      searchProvider.setDateRange(DateTime.now(), DateTime.now());

      // Act
      searchProvider.clearDateRange();

      // Assert
      expect(searchProvider.dateRangeStart, isNull);
      expect(searchProvider.dateRangeEnd, isNull);
    });
  });
}

