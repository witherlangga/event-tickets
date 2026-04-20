import 'package:flutter/material.dart';

class TransactionDetailPage extends StatelessWidget {
  final String id;
  final String event;
  final String date;
  final int total;
  const TransactionDetailPage({super.key, required this.id, required this.event, required this.date, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $id'),
            Text('Event: $event'),
            Text('Tanggal: $date'),
            Text('Total: Rp $total'),
            const SizedBox(height: 24),
            const Text('Detail tiket dan status pembayaran akan ditampilkan di sini.'),
          ],
        ),
      ),
    );
  }
}
