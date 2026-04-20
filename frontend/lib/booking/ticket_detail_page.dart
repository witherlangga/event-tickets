import 'package:flutter/material.dart';
import '../core/backend_services.dart';
import '../core/api_client.dart';

class TicketDetailPage extends StatefulWidget {
  final int? ticketId;
  const TicketDetailPage({super.key, this.ticketId});

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  Map? ticket;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.ticketId == null) return;
    setState(() => loading = true);
    try {
      final res = await BookingService().ticketDetail(widget.ticketId!);
      final data = res.data;
      if (!mounted) return;
      setState(() => ticket = data is Map && data.containsKey('data') ? data['data'] : data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat ticket')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Detail')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Code: ${ticket?['qr_code'] ?? ticket?['ticket_code'] ?? '-'}'),
                const SizedBox(height: 8),
                if (ticket?['qr_image_url'] != null && ticket!['qr_image_url'] != '')
                  Center(child: Image.network(ApiClient.resolveAssetUrl(ticket!['qr_image_url'].toString()), height: 220)),
                const SizedBox(height: 8),
                Text('Status: ${ticket?['status'] ?? '-'}'),
                const SizedBox(height: 8),
                Text('Event: ${ticket?['category']?['event']?['title'] ?? '-'}'),
              ]),
            ),
    );
  }
}
