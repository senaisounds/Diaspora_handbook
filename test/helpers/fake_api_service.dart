import 'package:diaspora_handbook/services/api_service.dart';
import 'package:dio/dio.dart';

class FakeApiService implements ApiService {
  Map<String, dynamic>? postResponse;
  Map<String, dynamic>? putResponse;
  dynamic getResponse; // Changed to dynamic to support both List and Map
  dynamic errorToThrow;
  String? token;


  @override
  Dio get _dio => throw UnimplementedError(); // Should not be accessed

  @override
  set _dio(Dio dio) => throw UnimplementedError();

  @override
  String get baseUrl => 'http://test';

  @override
  void setBaseUrl(String url) {}

  @override
  void setToken(String? t) {
    token = t;
  }

  @override
  Future<dynamic> get(String path) async {
    if (errorToThrow != null) throw errorToThrow!;
    return getResponse ?? (path.contains('/auth/user') ? {} : []);
  }

  @override
  Future<dynamic> post(String path, dynamic data) async {
    if (errorToThrow != null) throw errorToThrow!;
    return postResponse ?? {};
  }

  @override
  Future<dynamic> put(String path, dynamic data) async {
    if (errorToThrow != null) throw errorToThrow!;
    return putResponse ?? {};
  }

  @override
  Future<dynamic> delete(String path) async {
    if (errorToThrow != null) throw errorToThrow!;
    return {};
  }
  
  // Implement other methods as needed, returning dummies
  @override
  Future<bool> checkHealth() async => true;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
