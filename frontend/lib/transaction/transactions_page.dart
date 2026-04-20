import 'package:flutter/material.dart';
import '../core/backend_services.dart';
import '../core/api_client.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await TransactionService().getTransactions();
      if (!mounted) return;
      setState(() => transactions = res.data is Map && res.data.containsKey('data') ? res.data['data'] : []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat transactions')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView.builder(itemCount: transactions.length, itemBuilder: (context, i) {
        final t = transactions[i];
        Widget leading = const Icon(Icons.receipt);
        try {
          if (t['details'] != null && t['details'] is List && (t['details'] as List).isNotEmpty) {
            final first = (t['details'] as List)[0];
            final ticket = first['ticket'] ?? {};
            final raw = ticket != null ? (ticket['qr_image_url'] ?? ticket['qr_image'] ?? ticket['qr_code']) : null;
            if (raw != null && raw.toString().isNotEmpty) {
              leading = Image.network(ApiClient.resolveAssetUrl(raw.toString()), width: 56, height: 56, fit: BoxFit.cover);
            }
          }
        } catch (_) {}
        return ListTile(leading: leading, title: Text('ID ${t['id']} - ${t['status']}'), subtitle: Text('Rp ${t['total_amount']}'), onTap: () => Navigator.pushNamed(context, '/transaction-detail', arguments: {'id': t['id']}));
      }),
    );
  }
}
