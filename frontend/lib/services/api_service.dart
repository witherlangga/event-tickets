import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String token;
  ApiService(this.baseUrl, this.token);

  Future<List<dynamic>> fetchCategories(int eventId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/events/$eventId/ticket-categories'),
        headers: {'Authorization': 'Bearer $token'});
    if (res.statusCode == 200) {
      return json.decode(res.body) as List<dynamic>;
    }
    throw Exception('Failed to load categories: ${res.statusCode} ${res.body}');
  }

  Future<int> book(int eventId, int ticketCategoryId, int quantity) async {
    final res = await http.post(Uri.parse('$baseUrl/api/book'), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    }, body: json.encode({
      'event_id': eventId,
      'ticket_category_id': ticketCategoryId,
      'quantity': quantity
    }));

    if (res.statusCode == 201) {
      final data = json.decode(res.body);
      return data['transaction_id'];
    }

    final err = json.decode(res.body);
    throw Exception(err['message'] ?? err.toString());
  }
}
