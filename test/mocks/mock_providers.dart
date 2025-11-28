import 'package:mockito/mockito.dart';
import 'package:diaspora_handbook/providers/events_provider.dart';
import 'package:diaspora_handbook/providers/favorites_provider.dart';
import 'package:diaspora_handbook/providers/reminders_provider.dart';
import 'package:diaspora_handbook/providers/search_provider.dart';
import 'package:diaspora_handbook/providers/chat_provider.dart';
import 'package:diaspora_handbook/providers/achievements_provider.dart';
import 'package:diaspora_handbook/providers/checkins_provider.dart';
import 'package:diaspora_handbook/providers/settings_provider.dart';
import 'package:diaspora_handbook/providers/registration_provider.dart';

class MockEventsProvider extends Mock implements EventsProvider {}
class MockFavoritesProvider extends Mock implements FavoritesProvider {}
class MockRemindersProvider extends Mock implements RemindersProvider {}
class MockSearchProvider extends Mock implements SearchProvider {}
class MockChatProvider extends Mock implements ChatProvider {}
class MockAchievementsProvider extends Mock implements AchievementsProvider {}
class MockCheckInsProvider extends Mock implements CheckInsProvider {}
class MockSettingsProvider extends Mock implements SettingsProvider {}
class MockRegistrationProvider extends Mock implements RegistrationProvider {}

