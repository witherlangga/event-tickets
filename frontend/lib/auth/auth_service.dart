import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Response> login(String email, String password) async {
    return await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/register', data: data);
  }
}
