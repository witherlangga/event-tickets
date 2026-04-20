import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/backend_services.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int qty = 1;
  bool loading = false;
  Map? category;
  int? eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      category = args['category'];
      eventId = args['eventId'];
    }
  }

  Future<void> _book() async {
    if (category == null || eventId == null) return;
    setState(() => loading = true);
    try {
      final res = await BookingService().bookTicket({'event_id': eventId, 'ticket_category_id': category!['id'], 'quantity': qty});
      if (!mounted) return;
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking sukses')));
        Navigator.pushReplacementNamed(context, '/my-tickets');
      } else {
        final msg = res.data is Map && res.data.containsKey('message') ? res.data['message'] : res.data.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal booking: $msg')));
      }
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      if (e is DioException && e.response != null) {
        msg = e.response?.data?.toString() ?? e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal booking: $msg')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${category?['name'] ?? ''}')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Text('Price: Rp ${category?['price'] ?? '-'}'),
          const SizedBox(height: 8),
          Row(children: [
            IconButton(onPressed: () => setState(() => qty = (qty > 1 ? qty - 1 : 1)), icon: const Icon(Icons.remove)),
            Text('$qty'),
            IconButton(onPressed: () => setState(() => qty++), icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: loading ? null : _book, child: loading ? const CircularProgressIndicator() : const Text('Checkout')),
        ]),
      ),
    );
  }
}
