import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailPage extends StatelessWidget {
  final Map<String, dynamic> ticket; // expects ticket fields e.g. id, qr_code, event, status
  const TicketDetailPage({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qr = ticket['qr_code'] ?? '';
    final title = ticket['event_title'] ?? 'Ticket';
    final status = ticket['status'] ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('Tiket #${ticket['id'] ?? ''}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Status: $status'),
            const SizedBox(height: 20),
            if (qr.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(children: [
                    QrImage(
                      data: qr,
                      version: QrVersions.auto,
                      size: 220.0,
                    ),
                    const SizedBox(height: 12),
                    SelectableText(qr, textAlign: TextAlign.center),
                  ]),
                ),
              )
            else
              const Text('QR code tidak tersedia'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () { 
              // TODO: share or save QR as image
            }, child: const Text('Bagikan / Simpan')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () { Navigator.pop(context); }, child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }
}
