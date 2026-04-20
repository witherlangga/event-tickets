import 'package:flutter/material.dart';
import '../core/backend_services.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  List tickets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await BookingService().myTickets();
      final data = res.data;
      if (!mounted) return;
      setState(() => tickets = data is Map && data.containsKey('data') ? data['data'] : []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat tiket')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, i) {
                final t = tickets[i];
                return ListTile(
                  title: Text(t['ticket_code'] ?? t['qr_code'] ?? 'Ticket #${t['id'] ?? ''}'),
                  subtitle: Text(t['status'] ?? '-'),
                  onTap: () => Navigator.pushNamed(context, '/ticket-detail', arguments: {'id': t['id']}),
                );
              },
            ),
    );
  }
}
