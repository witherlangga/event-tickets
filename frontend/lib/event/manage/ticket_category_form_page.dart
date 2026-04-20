import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api_client.dart';

class TicketCategoryFormPage extends StatefulWidget {
  final int eventId;
  final Map<String, dynamic>? initial;
  const TicketCategoryFormPage({Key? key, required this.eventId, this.initial}) : super(key: key);

  @override
  _TicketCategoryFormPageState createState() => _TicketCategoryFormPageState();
}

class _TicketCategoryFormPageState extends State<TicketCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _quotaCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  final _saleStartCtrl = TextEditingController();
  final _saleEndCtrl = TextEditingController();
  DateTime? _saleStart;
  DateTime? _saleEnd;
  String _status = 'published';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _nameCtrl.text = init['name']?.toString() ?? '';
      _descCtrl.text = init['description']?.toString() ?? '';
      _priceCtrl.text = init['price'] != null ? init['price'].toString() : '';
      _quotaCtrl.text = init['quota'] != null ? init['quota'].toString() : '';
      _limitCtrl.text = init['per_person_limit'] != null ? init['per_person_limit'].toString() : '';
      if (init['sale_start'] != null) {
        final dt = DateTime.tryParse(init['sale_start'].toString());
        if (dt != null) {
          _saleStart = dt;
          _saleStartCtrl.text = dt.toLocal().toString().split('.').first;
        }
      }
      if (init['sale_end'] != null) {
        final dt2 = DateTime.tryParse(init['sale_end'].toString());
        if (dt2 != null) {
          _saleEnd = dt2;
          _saleEndCtrl.text = dt2.toLocal().toString().split('.').first;
        }
      }
      if (init['status'] != null) _status = init['status'];
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'quota': int.tryParse(_quotaCtrl.text.trim()) ?? 0,
        'per_person_limit': int.tryParse(_limitCtrl.text.trim()) ?? 0,
        'sale_start': _saleStart?.toIso8601String(),
        'sale_end': _saleEnd?.toIso8601String(),
        'status': _status,
      };

      Response res;
      final init = widget.initial;
      final isEdit = init != null && init['id'] != null;
      if (isEdit) {
        final id = init['id'];
        res = await ApiClient().dio.put('/organizer/events/${widget.eventId}/ticket-categories/$id', data: data);
      } else {
        res = await ApiClient().dio.post('/organizer/events/${widget.eventId}/ticket-categories', data: data);
      }

      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Kategori tiket berhasil diperbarui' : 'Kategori tiket berhasil dibuat')));
        Navigator.pop(context, true);
      } else {
        final msg = res.data is Map && res.data.containsKey('message') ? res.data['message'] : res.data.toString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
      }
    } catch (e) {
      String msg = e.toString();
      if (e is DioException && e.response != null) {
        msg = e.response?.data?.toString() ?? e.toString();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isEdit = widget.initial != null && widget.initial!['id'] != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Kategori Tiket' : 'Tambah Kategori Tiket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Kategori'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga (Rp)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                  final n = double.tryParse(v.trim());
                  if (n == null) return 'Masukkan angka yang valid';
                  if (n < 0) return 'Harga tidak boleh negatif';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _quotaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Kuota'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Kuota wajib diisi';
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Masukkan bilangan bulat';
                    if (n < 0) return 'Kuota tidak boleh negatif';
                    return null;
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _limitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Limit per orang (0 = tak terbatas)'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Nilai wajib diisi';
                    final n = int.tryParse(v.trim());
                    if (n == null) return 'Masukkan bilangan bulat';
                    if (n < 0) return 'Tidak boleh negatif';
                    return null;
                  },
                )),
              ]),

              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(
                  controller: _saleStartCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Mulai penjualan (opsional)'),
                  onTap: () async {
                    final dt = await showDatePicker(context: context, initialDate: _saleStart ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 3650)));
                    if (dt != null) {
                      final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_saleStart ?? DateTime.now()));
                      if (tm != null) {
                        setState(() {
                          _saleStart = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute);
                          _saleStartCtrl.text = _saleStart!.toLocal().toString().split('.').first;
                        });
                      }
                    }
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(
                  controller: _saleEndCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Akhir penjualan (opsional)'),
                  onTap: () async {
                    final dt = await showDatePicker(context: context, initialDate: _saleEnd ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 3650)));
                    if (dt != null) {
                      final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_saleEnd ?? DateTime.now()));
                      if (tm != null) {
                        setState(() {
                          _saleEnd = DateTime(dt.year, dt.month, dt.day, tm.hour, tm.minute);
                          _saleEndCtrl.text = _saleEnd!.toLocal().toString().split('.').first;
                        });
                      }
                    }
                  },
                )),
              ]),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'published', child: Text('Published')),
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'hidden', child: Text('Hidden')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'published'),
                decoration: const InputDecoration(labelText: 'Status'),
              ),

              const SizedBox(height: 16),
              Text('Preview', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_nameCtrl.text.isEmpty ? 'Nama Kategori' : _nameCtrl.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(_descCtrl.text.isEmpty ? 'Deskripsi singkat kategori tiket.' : _descCtrl.text),
                    const SizedBox(height: 8),
                    Text(_priceCtrl.text.isEmpty ? 'Harga: -' : 'Harga: ${currency.format(double.tryParse(_priceCtrl.text.replaceAll('.', '')) ?? 0)}'),
                    const SizedBox(height: 4),
                    Text('Kuota: ${_quotaCtrl.text.isEmpty ? '-' : _quotaCtrl.text}'),
                    const SizedBox(height: 4),
                    Text('Limit per orang: ${_limitCtrl.text.isEmpty ? 'Tak terbatas' : _limitCtrl.text}'),
                    const SizedBox(height: 4),
                    if (_saleStart != null) Text('Penjualan mulai: ${_saleStart!.toLocal().toString().split('.').first}'),
                    if (_saleEnd != null) Text('Penjualan berakhir: ${_saleEnd!.toLocal().toString().split('.').first}'),
                    const SizedBox(height: 6),
                    Text('Status: ${_status[0].toUpperCase()}${_status.substring(1)}'),
                  ]),
                ),
              ),

              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)) : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
