import 'package:flutter/material.dart';

class QrScannerPage extends StatelessWidget {
  const QrScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Check-in')),
      body: const Center(
        child: Text('Fitur scan QR akan di sini'),
      ),
    );
  }
}
