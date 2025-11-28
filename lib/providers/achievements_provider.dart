import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AchievementType {
  firstFavorite('First Favorite', '🌟', 'Favorite your first event'),
  partyAnimal('Party Animal', '🎉', 'Favorite 5 party events'),
  cultureExplorer('Culture Explorer', '🎭', 'Favorite 5 cultural events'),
  earlyBird('Early Bird', '🐦', 'Set 3 reminders'),
  socialButterfly('Social Butterfly', '🦋', 'Check in to 5 events'),
  homecomingHero('Homecoming Hero', '👑', 'Check in to 10 events'),
  plannerPro('Planner Pro', '📅', 'Favorite 10 events'),
  explorer('Explorer', '🗺️', 'View map 5 times'),
  categoryCollector('Category Collector', '🏷️', 'Explore 5 different categories'),
  allStar('All Star', '⭐', 'Complete all achievements');

  final String title;
  final String emoji;
  final String description;

  const AchievementType(this.title, this.emoji, this.description);
}

class Achievement {
  final AchievementType type;
  final DateTime unlockedAt;

  Achievement({required this.type, required this.unlockedAt});
}

class AchievementsProvider extends ChangeNotifier {
  final Map<AchievementType, Achievement> _achievements = {};
  final List<Achievement> _unlockedAchievements = [];

  List<Achievement> get unlockedAchievements => List.unmodifiable(_unlockedAchievements);
  Map<AchievementType, Achievement> get achievements => Map.unmodifiable(_achievements);
  int get totalAchievements => AchievementType.values.length;
  int get unlockedCount => _unlockedAchievements.length;

  AchievementsProvider() {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList('unlockedAchievements') ?? [];
    
    for (final id in unlockedIds) {
      final type = AchievementType.values.firstWhere(
        (e) => e.name == id,
        orElse: () => AchievementType.firstFavorite,
      );
      final timestamp = prefs.getInt('achievement_$id') ?? DateTime.now().millisecondsSinceEpoch;
      
      final achievement = Achievement(
        type: type,
        unlockedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
      _achievements[type] = achievement;
      _unlockedAchievements.add(achievement);
    }
    
    _unlockedAchievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    notifyListeners();
  }

  bool isUnlocked(AchievementType type) {
    return _achievements.containsKey(type);
  }

  Future<bool> checkAndUnlock(AchievementType type) async {
    if (isUnlocked(type)) return false;

    final achievement = Achievement(
      type: type,
      unlockedAt: DateTime.now(),
    );

    _achievements[type] = achievement;
    _unlockedAchievements.add(achievement);
    _unlockedAchievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));

    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList('unlockedAchievements') ?? [];
    unlockedIds.add(type.name);
    await prefs.setStringList('unlockedAchievements', unlockedIds);
    await prefs.setInt('achievement_${type.name}', achievement.unlockedAt.millisecondsSinceEpoch);

    notifyListeners();
    return true;
  }

  Future<bool> checkAchievements({
    int favoriteCount = 0,
    int checkInCount = 0,
    int reminderCount = 0,
    int partyFavoriteCount = 0,
    int cultureFavoriteCount = 0,
    int categoryCount = 0,
    int mapViewCount = 0,
  }) async {
    bool unlocked = false;

    if (favoriteCount >= 1 && !isUnlocked(AchievementType.firstFavorite)) {
      unlocked = await checkAndUnlock(AchievementType.firstFavorite) || unlocked;
    }

    if (partyFavoriteCount >= 5 && !isUnlocked(AchievementType.partyAnimal)) {
      unlocked = await checkAndUnlock(AchievementType.partyAnimal) || unlocked;
    }

    if (cultureFavoriteCount >= 5 && !isUnlocked(AchievementType.cultureExplorer)) {
      unlocked = await checkAndUnlock(AchievementType.cultureExplorer) || unlocked;
    }

    if (reminderCount >= 3 && !isUnlocked(AchievementType.earlyBird)) {
      unlocked = await checkAndUnlock(AchievementType.earlyBird) || unlocked;
    }

    if (checkInCount >= 5 && !isUnlocked(AchievementType.socialButterfly)) {
      unlocked = await checkAndUnlock(AchievementType.socialButterfly) || unlocked;
    }

    if (checkInCount >= 10 && !isUnlocked(AchievementType.homecomingHero)) {
      unlocked = await checkAndUnlock(AchievementType.homecomingHero) || unlocked;
    }

    if (favoriteCount >= 10 && !isUnlocked(AchievementType.plannerPro)) {
      unlocked = await checkAndUnlock(AchievementType.plannerPro) || unlocked;
    }

    if (categoryCount >= 5 && !isUnlocked(AchievementType.categoryCollector)) {
      unlocked = await checkAndUnlock(AchievementType.categoryCollector) || unlocked;
    }

    // Check if all achievements are unlocked (excluding allStar itself)
    if (_unlockedAchievements.length >= totalAchievements - 1 && !isUnlocked(AchievementType.allStar)) {
      unlocked = await checkAndUnlock(AchievementType.allStar) || unlocked;
    }

    return unlocked;
  }

  Future<void> resetAchievements() async {
    _achievements.clear();
    _unlockedAchievements.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('unlockedAchievements');
    
    for (final type in AchievementType.values) {
      await prefs.remove('achievement_${type.name}');
    }
    
    notifyListeners();
  }
}

