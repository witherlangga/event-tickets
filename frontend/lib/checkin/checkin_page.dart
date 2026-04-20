import 'package:flutter/material.dart';
import '../core/api_client.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _code = TextEditingController();
  bool loading = false;

  Future<void> _scan() async {
    setState(() => loading = true);
    try {
      final res = await ApiClient().dio.post('/check-in', data: {'code': _code.text});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message'] ?? 'Checked in')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal check-in: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-In')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: _code, decoration: const InputDecoration(labelText: 'Ticket QR/Code')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: loading ? null : _scan, child: loading ? const CircularProgressIndicator() : const Text('Check-In')),
        ]),
      ),
    );
  }
}
