import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class OrganizerSalesPage extends StatefulWidget {
  const OrganizerSalesPage({super.key});

  @override
  State<OrganizerSalesPage> createState() => _OrganizerSalesPageState();
}

class _OrganizerSalesPageState extends State<OrganizerSalesPage> {
  Map? data;
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final ev = args?['event'];
    if (ev != null) {
      _load(ev['id']);
    }
  }

  Future<void> _load(int eventId) async {
    setState(() => loading = true);
    try {
      final res = await ApiClient().dio.get('/organizer/events/$eventId/sales');
      setState(() => data = res.data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat ringkasan')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Penjualan')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text('Tidak ada data'))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(data!['event']?['title'] ?? 'Event', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Total Pendapatan: Rp ${data!['total_revenue'] ?? 0}'),
                    Text('Total Transaksi: ${data!['total_transactions'] ?? 0}'),
                    Text('Tiket Terjual: ${data!['tickets_sold'] ?? 0}'),
                    const SizedBox(height: 12),
                    const Text('Per Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: (data!['by_category'] as List?)?.length ?? 0,
                        itemBuilder: (context, i) {
                          final c = data!['by_category'][i];
                          return ListTile(
                            title: Text(c['name'] ?? '-'),
                            subtitle: Text('Terjual: ${c['sold'] ?? 0} — Pendapatan: Rp ${c['revenue'] ?? 0}'),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
    );
  }
}
