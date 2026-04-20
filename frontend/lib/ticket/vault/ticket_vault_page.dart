import 'package:flutter/material.dart';

class TicketVaultPage extends StatelessWidget {
  const TicketVaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data tiket
    final tickets = [
      {'event': 'Music Concert', 'date': '2026-05-01', 'code': 'TCK123'},
      {'event': 'Tech Conference', 'date': '2026-06-10', 'code': 'TCK456'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiket Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.pushNamed(context, '/qr-scanner');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return ListTile(
            title: Text(ticket['event']!),
            subtitle: Text('Tanggal: ${ticket['date']}'),
            trailing: IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/ticket-detail',
                  arguments: {
                    'event': ticket['event'],
                    'date': ticket['date'],
                    'code': ticket['code'],
                  },
                );
              },
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/ticket-detail',
                arguments: {
                  'event': ticket['event'],
                  'date': ticket['date'],
                  'code': ticket['code'],
                },
              );
            },
          );
        },
      ),
    );
  }
}
