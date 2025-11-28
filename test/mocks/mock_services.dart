import 'package:mockito/mockito.dart';
import 'package:diaspora_handbook/services/api_service.dart';
import 'package:diaspora_handbook/services/notification_service.dart';
import 'package:diaspora_handbook/services/ad_service.dart';
import 'package:diaspora_handbook/services/connectivity_service.dart';

class MockApiService extends Mock implements ApiService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockAdService extends Mock implements AdService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

