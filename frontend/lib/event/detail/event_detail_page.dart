import 'package:flutter/material.dart';
import '../../core/backend_services.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;
  final String eventTitle;
  final String eventDate;
  const EventDetailPage({super.key, required this.eventId, required this.eventTitle, required this.eventDate});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Map? event;
  List categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await EventService().getEventDetail(widget.eventId);
      final data = res.data;
      event = data is Map && data.containsKey('data') ? data['data'] : data;
      if (event != null) {
        final t = await TicketCategoryService().getTicketCategories(widget.eventId);
        categories = t.data is Map && t.data.containsKey('data') ? t.data['data'] : [];
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat detail')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventTitle)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tanggal: ${widget.eventDate}'),
                const SizedBox(height: 8),
                Text(event?['description'] ?? '-'),
                const SizedBox(height: 16),
                const Text('Ticket Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...categories.map((c) => ListTile(
                      title: Text(c['name'] ?? '-'),
                      subtitle: Text('Rp ${c['price']} - Quota: ${c['quota'] ?? 0}'),
                      trailing: ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/booking', arguments: {'eventId': widget.eventId, 'category': c}),
                        child: const Text('Book'),
                      ),
                    )),
              ]),
            ),
    );
  }
}
