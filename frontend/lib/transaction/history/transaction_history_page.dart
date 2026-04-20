import 'package:flutter/material.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data transaksi
    final transactions = [
      {'id': 'TRX001', 'event': 'Music Concert', 'date': '2026-05-01', 'total': 500000},
      {'id': 'TRX002', 'event': 'Tech Conference', 'date': '2026-06-10', 'total': 150000},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final trx = transactions[index];
          return ListTile(
            title: Text(trx['event']!),
            subtitle: Text('Tanggal: ${trx['date']}'),
            trailing: Text('Rp ${trx['total']}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/transaction-detail',
                arguments: {
                  'id': trx['id'],
                  'event': trx['event'],
                  'date': trx['date'],
                  'total': trx['total'],
                },
              );
            },
          );
        },
      ),
    );
  }
}
