import 'package:dio/dio.dart';
import '../core/api_client.dart';

class EventService {
  final Dio _dio = ApiClient().dio;

  Future<Response> getEvents() async {
    return await _dio.get('/events');
  }

  Future<Response> getEventDetail(int id) async {
    return await _dio.get('/events/id');
  }
}

class TicketCategoryService {
  final Dio _dio = ApiClient().dio;

  Future<Response> getTicketCategories(int eventId) async {
    return await _dio.get('/events/$eventId/ticket-categories');
  }
}

class BookingService {
  final Dio _dio = ApiClient().dio;

  Future<Response> bookTicket(Map<String, dynamic> data) async {
    return await _dio.post('/book', data: data);
  }

  Future<Response> myTickets() async {
    return await _dio.get('/my-tickets');
  }

  Future<Response> ticketDetail(int id) async {
    return await _dio.get('/my-tickets/$id');
  }
}

class TransactionService {
  final Dio _dio = ApiClient().dio;

  Future<Response> getTransactions() async {
    return await _dio.get('/transactions');
  }

  Future<Response> getTransactionDetail(int id) async {
    return await _dio.get('/transactions/$id');
  }
}

class ProfileService {
  final Dio _dio = ApiClient().dio;

  Future<Response> getProfile() async {
    return await _dio.get('/profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await _dio.put('/profile', data: data);
  }
}
