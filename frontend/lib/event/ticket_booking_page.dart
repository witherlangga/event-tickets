import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class TicketCategory {
  final int id;
  final String name;
  final double price;
  final int quota;
  final int sold;
  TicketCategory({required this.id, required this.name, required this.price, required this.quota, required this.sold});
  factory TicketCategory.fromJson(Map<String, dynamic> j) => TicketCategory(
    id: j['id'],
    name: j['name'],
    price: (j['price'] is String) ? double.parse(j['price']) : (j['price'] as num).toDouble(),
    quota: j['quota'] ?? 0,
    sold: j['sold'] ?? 0,
  );
}

class TicketBookingPage extends StatefulWidget {
  final int eventId;
  final String baseUrl;
  const TicketBookingPage({Key? key, required this.eventId, required this.baseUrl}) : super(key: key);

  @override
  _TicketBookingPageState createState() => _TicketBookingPageState();
}

class _TicketBookingPageState extends State<TicketBookingPage> {
  bool loading = false;
  List<TicketCategory> categories = [];
  TicketCategory? selected;
  int qty = 1;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<String> _getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('auth_token') ?? '';
  }

  Future<void> loadCategories() async {
    setState(() => loading = true);
    try {
      final token = await _getToken();
      final svc = ApiService(widget.baseUrl, token);
      final list = await svc.fetchCategories(widget.eventId);
      setState(() => categories = list.map((e) => TicketCategory.fromJson(e as Map<String, dynamic>)).toList());
      if (categories.isNotEmpty) selected = categories.first;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat kategori: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> doBook() async {
    if (selected == null) return;
    setState(() => loading = true);
    try {
      final token = await _getToken();
      final svc = ApiService(widget.baseUrl, token);
      final txId = await svc.book(widget.eventId, selected!.id, qty);
      await showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Berhasil'),
        content: Text('Transaksi: $txId'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ));
      // Optionally navigate to MyTickets or refresh
    } catch (e) {
      await showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('Gagal'),
        content: Text(e.toString()),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beli Tiket')),
      body: loading && categories.isEmpty ? Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Kategori', style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 12),
            if (categories.isEmpty) Text('Tidak ada kategori tiket.'),
            if (categories.isNotEmpty) ...[
              DropdownButton<TicketCategory>(
                isExpanded: true,
                value: selected,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text('${c.name} - Rp ${c.price.toStringAsFixed(0)}'))).toList(),
                onChanged: (v) => setState(() => selected = v),
              ),
              SizedBox(height: 12),
              Row(children: [
                Text('Jumlah:'),
                SizedBox(width: 12),
                IconButton(onPressed: qty>1 ? () => setState(()=>qty--) : null, icon: Icon(Icons.remove)),
                Text('$qty'),
                IconButton(onPressed: selected!=null && (selected!.quota - selected!.sold) > qty ? () => setState(()=>qty++) : null, icon: Icon(Icons.add)),
                SizedBox(width: 16),
                Text('Sisa: ${selected!=null ? (selected!.quota - selected!.sold) : 0}'),
              ]),
              Spacer(),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: loading ? null : doBook,
                child: loading ? CircularProgressIndicator(color: Colors.white) : Text('Bayar & Pesan'),
              ))
            ]
          ],
        ),
      ),
    );
  }
}
