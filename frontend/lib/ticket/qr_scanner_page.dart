import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _processing = false;
  String? _lastScanned;
  String _message = '';

  Future<void> _processCode(String code) async {
    if (_processing) return;
    setState(() {
      _processing = true;
      _lastScanned = code;
      _message = 'Memproses...';
    });
    try {
      final res = await ApiClient().dio.post('/check-in', data: {'qr_code': code});
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        setState(() {
          _message = res.data is Map && res.data.containsKey('message') ? res.data['message'] : 'Check-in berhasil';
        });
      } else {
        setState(() {
          _message = res.data is Map && res.data.containsKey('message') ? res.data['message'] : 'Gagal: ' + res.data.toString();
        });
      }
    } catch (e) {
      String msg = e.toString();
      if (e is DioException && e.response != null) msg = e.response?.data?.toString() ?? e.toString();
      setState(() {
        _message = 'Error: $msg';
      });
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Check-in')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  allowDuplicates: false,
                  onDetect: (barcode, args) {
                    final String? code = barcode.rawValue;
                    if (code != null) {
                      _processCode(code);
                    }
                  },
                ),
                if (_processing)
                  Container(
                    color: Colors.black45,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hasil: ${_lastScanned ?? '-'}'),
                const SizedBox(height: 6),
                Text(_message, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
                  const SizedBox(width: 12),
                  ElevatedButton(onPressed: () => setState(() { _lastScanned = null; _message = ''; }), child: const Text('Reset')),                
                ]),
              ],
            ),
          )
        ],
      ),
    );
  }
}
