import 'package:dio/dio.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api'; // Ganti sesuai URL backend
  final Dio _dio;

  ApiClient._internal(this._dio);

  static final ApiClient _instance = ApiClient._internal(
    Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    )),
  );

  factory ApiClient() => _instance;

  Dio get dio => _dio;
}
