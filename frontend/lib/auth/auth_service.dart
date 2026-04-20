import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Response> login(String email, String password) async {
    final res = await _dio.post('/login', data: {'email': email, 'password': password});
    if (res.data != null && res.data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res.data['token']);
    }
    return res;
  }

  Future<Response> register(Map<String, dynamic> data) async {
    final res = await _dio.post('/register', data: data);
    if (res.data != null && res.data['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res.data['token']);
    }
    return res;
  }

  Future<void> logout() async {
    await _dio.post('/logout');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
