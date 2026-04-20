import 'package:flutter/material.dart';
import '../core/api_client.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List users = [];
  List transactions = [];
  List organizers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final u = await ApiClient().dio.get('/admin/users');
      final t = await ApiClient().dio.get('/admin/transactions');
      final o = await ApiClient().dio.get('/admin/organizers');
      setState(() {
        users = u.data is Map && u.data.containsKey('data') ? u.data['data'] : [];
        transactions = t.data is Map && t.data.containsKey('data') ? t.data['data'] : [];
        organizers = o.data is Map && o.data.containsKey('data') ? o.data['data'] : [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat admin data')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _purge() async {
    try {
      await ApiClient().dio.post('/admin/events/purge');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Events purged')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal purge: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(padding: const EdgeInsets.all(12), children: [
                const Text('Users', style: TextStyle(fontWeight: FontWeight.bold)),
                ...users.map((u) => ListTile(title: Text(u['name'] ?? '-'), subtitle: Text(u['email'] ?? '-'))),
                const SizedBox(height: 12),
                const Text('Organizers', style: TextStyle(fontWeight: FontWeight.bold)),
                ...organizers.map((o) => ListTile(title: Text(o['organization_name'] ?? '-'))),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _purge, child: const Text('Purge Events')),
                const SizedBox(height: 12),
                const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
                ...transactions.map((t) => ListTile(title: Text('ID ${t['id']} - ${t['status']}'), subtitle: Text('Rp ${t['total_amount']}'))),
              ]),
            ),
    );
  }
}
