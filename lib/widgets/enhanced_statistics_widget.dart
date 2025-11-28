import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/checkins_provider.dart';
import '../providers/achievements_provider.dart';
import 'statistics_widget.dart';

class EnhancedStatisticsWidget extends StatelessWidget {
  const EnhancedStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<FavoritesProvider, CheckInsProvider, AchievementsProvider>(
      builder: (context, favoritesProvider, checkInsProvider, achievementsProvider, child) {
        final favoriteCount = favoritesProvider.favoriteEvents.length;
        final checkInCount = checkInsProvider.totalCheckIns;
        final achievementCount = achievementsProvider.unlockedCount;
        final totalAchievements = achievementsProvider.totalAchievements;

        // Count favorites by category
        final favoriteEvents = favoritesProvider.favoriteEvents;
        final categoryCounts = <String, int>{};
        for (var event in favoriteEvents) {
          categoryCounts[event.category] = (categoryCounts[event.category] ?? 0) + 1;
        }

        final topCategory = categoryCounts.entries.isNotEmpty
            ? categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b)
            : null;

        return Column(
          children: [
            // User Stats Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700).withOpacity(0.2),
                    const Color(0xFFFFD700).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                      const SizedBox(width: 8),
                      Text(
                        'Your Homecoming Stats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFD700),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUserStatCard(
                          context,
                          'Favorites',
                          favoriteCount.toString(),
                          Icons.favorite,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildUserStatCard(
                          context,
                          'Check-ins',
                          checkInCount.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildUserStatCard(
                          context,
                          'Achievements',
                          '$achievementCount/$totalAchievements',
                          Icons.stars,
                          Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildUserStatCard(
                          context,
                          'Categories',
                          categoryCounts.length.toString(),
                          Icons.category,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  if (topCategory != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, color: Color(0xFFFFD700)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Top Category',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${topCategory.key} (${topCategory.value})',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFFD700),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Original Statistics Widget
            const StatisticsWidget(),
          ],
        );
      },
    );
  }

  Widget _buildUserStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

