import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final String eventTitle;
  final String eventDate;
  const EventDetailPage({super.key, required this.eventTitle, required this.eventDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: $eventDate', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Deskripsi event akan ditampilkan di sini.'),
            const SizedBox(height: 24),
            const Text('Kategori Tiket:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('VIP'),
              subtitle: const Text('Rp 500.000'),
              trailing: ElevatedButton(
                onPressed: null, // Nanti untuk booking
                child: const Text('Pesan'),
              ),
            ),
            ListTile(
              title: const Text('Reguler'),
              subtitle: const Text('Rp 150.000'),
              trailing: ElevatedButton(
                onPressed: null, // Nanti untuk booking
                child: const Text('Pesan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
