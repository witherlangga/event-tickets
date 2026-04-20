import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Default base, overridden below depending on platform (emulator vs device)
  // For web, use localhost. For mobile emulators, 10.0.2.2 is commonly used for Android.
  // If you need other host (physical device), override manually here.
  static final String baseUrl = kIsWeb ? 'http://localhost:8000/api' : 'http://10.0.2.2:8000/api';
  final Dio _dio;

  ApiClient._internal(this._dio) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        try {
          final d = response.data;
          if (d is Map) {
            // normalize common keys to `data` so UI code can read consistently
            if (!d.containsKey('data')) {
              if (d.containsKey('events')) d['data'] = d['events'];
              else if (d.containsKey('event')) d['data'] = d['event'];
              else if (d.containsKey('categories')) d['data'] = d['categories'];
              else if (d.containsKey('user')) d['data'] = d['user'];
            }
          }
        } catch (_) {}
        return handler.next(response);
      },
    ));
  }

  static final ApiClient _instance = ApiClient._internal(
    Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
      // Accept 4xx responses so the UI can read validation errors (422) instead of throwing
      validateStatus: (status) => status != null && status < 500,
    )),
  );

  factory ApiClient() => _instance;

  Dio get dio => _dio;

  /// Resolve asset/storage path returned from backend to a full URL usable by Image.network
  /// Handles several backend formats:
  /// - absolute URL starting with http(s)
  /// - path starting with '/storage/...'
  /// - storage relative path like 'avatars/..' or 'qrcodes/...'
  static String resolveAssetUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    var base = baseUrl;
    var host = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
    if (host.endsWith('/')) host = host.substring(0, host.length - 1);
    if (raw.startsWith('/')) {
      return host + raw;
    }
    if (raw.startsWith('storage/')) {
      return host + '/' + raw;
    }
    return host + '/storage/' + raw;
  }
}
