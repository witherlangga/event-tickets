import 'package:flutter/material.dart';

class TicketDetailPage extends StatelessWidget {
  final String event;
  final String date;
  final String code;
  const TicketDetailPage({super.key, required this.event, required this.date, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tiket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: $event', style: const TextStyle(fontSize: 18)),
            Text('Tanggal: $date'),
            Text('Kode: $code'),
            const SizedBox(height: 24),
            Center(
              child: Container(
                color: Colors.grey[200],
                width: 200,
                height: 200,
                child: const Center(child: Text('QR Code')), // Nanti diganti widget QR
              ),
            ),
          ],
        ),
      ),
    );
  }
}
