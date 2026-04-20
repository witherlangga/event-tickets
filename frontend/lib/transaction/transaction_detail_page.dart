import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../core/backend_services.dart';
import '../core/api_client.dart';

class TransactionDetailPage extends StatefulWidget {
  final int id;
  const TransactionDetailPage({super.key, required this.id});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  Map? tx;
  bool loading = true;
  XFile? _pickedImage;
  Uint8List? _pickedBytes;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await TransactionService().getTransactionDetail(widget.id);
      setState(() => tx = res.data['data'] ?? res.data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat transaction')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (f == null) return;
      final bytes = await f.readAsBytes();
      setState(() {
        _pickedImage = f;
        _pickedBytes = bytes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal pilih gambar: $e')));
    }
  }

  Future<void> _uploadProof() async {
    if (_pickedImage == null) return;
    setState(() => _uploading = true);
    try {
      final res = await TransactionService().uploadProof(widget.id, _pickedImage!);
      if (!mounted) return;
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload bukti berhasil')));
        await _load();
        setState(() {
          _pickedImage = null;
          _pickedBytes = null;
        });
      } else {
        final msg = res.data is Map && res.data.containsKey('message') ? res.data['message'] : res.data.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload gagal: $msg')));
      }
    } catch (e) {
      String msg = e.toString();
      if (e is DioException && e.response != null) {
        msg = e.response?.data?.toString() ?? e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saat upload: $msg')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(title: Text('Transaction #${widget.id}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Status: ${tx?['status'] ?? '-'}'),
                Text('Total: Rp ${tx?['total_amount'] ?? '-'}'),
                const SizedBox(height: 12),
                const Text('Tickets:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (tx != null && tx!['details'] is List)
                  ...((tx!['details'] as List).map((d) {
                    final ticket = d['ticket'] ?? {};
                    final raw = ticket != null ? (ticket['qr_image_url'] ?? ticket['qr_image'] ?? ticket['qr_code']) : null;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Ticket ID: ${ticket?['id'] ?? '-'}'),
                          Text('Status: ${ticket?['status'] ?? '-'}'),
                          const SizedBox(height: 8),
                          if (raw != null && raw.toString().isNotEmpty)
                            Center(child: Image.network(ApiClient.resolveAssetUrl(raw.toString()), height: 220)),
                          if (raw == null || raw.toString().isEmpty) const Text('QR code not available yet'),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      const Text('Payment Proof', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (tx != null && tx!['proof_path'] != null && tx!['proof_path'].toString().isNotEmpty)
                        Center(child: Image.network(ApiClient.resolveAssetUrl(tx!['proof_path'].toString()), height: 220)),
                      if (tx == null || tx!['proof_path'] == null || tx!['proof_path'].toString().isEmpty) ...[
                        if (_pickedBytes != null) Center(child: Image.memory(_pickedBytes!, height: 220)),
                        const SizedBox(height: 8),
                        Row(children: [
                          ElevatedButton(onPressed: _pickImage, child: const Text('Pilih Foto Bukti')),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: (_pickedImage == null || _uploading) ? null : _uploadProof, child: _uploading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Upload')),
                        ])
                      ]
                    );
                  }).toList()),
              ]),
            ),
    );
  }
}
