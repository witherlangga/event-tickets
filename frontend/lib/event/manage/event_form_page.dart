import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../core/api_client.dart';
import 'map_picker_page.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({super.key});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  XFile? _image;
  bool loading = false;
  int? eventId;
  DateTime? _startDateTime;
  DateTime? _endDateTime;
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  String _status = 'draft';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final ev = args?['event'];
    if (ev != null && eventId == null) {
      eventId = ev['id'];
      _title.text = ev['title'] ?? '';
      _desc.text = ev['description'] ?? '';
      _location.text = ev['location'] ?? '';
      // populate new fields if present
      if (ev['start_time'] != null) {
        final dt = DateTime.tryParse(ev['start_time']);
        if (dt != null) {
          _startDateTime = dt;
          _startController.text = dt.toLocal().toString().split('.').first;
        }
      }
      if (ev['end_time'] != null) {
        final dt2 = DateTime.tryParse(ev['end_time']);
        if (dt2 != null) {
          _endDateTime = dt2;
          _endController.text = dt2.toLocal().toString().split('.').first;
        }
      }
      if (ev['latitude'] != null) {
        // try assign lat/lng
        try {
          _latController.text = (ev['latitude'] ?? '').toString();
        } catch (_) {}
      }
      if (ev['longitude'] != null) {
        try {
          _lngController.text = (ev['longitude'] ?? '').toString();
        } catch (_) {}
      }
      if (ev['status'] != null) _status = ev['status'];
    }
  }

  Future<void> _pick() async {
    final p = ImagePicker();
    final f = await p.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null) setState(() => _image = f);
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()));
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    setState(() => loading = true);
    try {
      final map = {
        'title': _title.text,
        'description': _desc.text,
        'location': _location.text,
        'start_time': _startDateTime?.toIso8601String(),
        'end_time': _endDateTime?.toIso8601String(),
        'latitude': _latController.text.isNotEmpty ? double.tryParse(_latController.text) : null,
        'longitude': _lngController.text.isNotEmpty ? double.tryParse(_lngController.text) : null,
        'status': _status,
      };
      MultipartFile? filePart;
      if (_image != null) {
        if (kIsWeb) {
          final bytes = await _image!.readAsBytes();
          filePart = MultipartFile.fromBytes(bytes, filename: _image!.name);
        } else {
          filePart = MultipartFile.fromFileSync(_image!.path, filename: _image!.name);
        }
      }

      final form = FormData.fromMap({
        ...map,
        if (filePart != null) 'banner': filePart,
      });
      final res = eventId == null
          ? await ApiClient().dio.post('/events', data: form)
          : await ApiClient().dio.put('/events/$eventId', data: form);

      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        if (!mounted) return;
        // jika baru dibuat, arahkan ke halaman kategori tiket untuk event ini
        if (eventId == null) {
          dynamic created;
          if (res.data is Map) {
            created = res.data['event'] ?? res.data['data'] ?? res.data;
          } else {
            created = res.data;
          }
          final id = created is Map && created['id'] != null ? created['id'] : null;
          if (id != null) {
            Navigator.pushNamed(context, '/events/{eventId}/ticket-categories', arguments: {'eventId': id}).then((_) => Navigator.pop(context));
            return;
          }
        }

        Navigator.pop(context);
      } else {
        final msg = res.data is Map && res.data.containsKey('message') ? res.data['message'] : res.data.toString();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $msg')));
      }
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      if (e is DioException && e.response != null) {
        msg = e.response?.data?.toString() ?? e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $msg')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventId == null ? 'Create Event' : 'Edit Event')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              const SizedBox(height: 8),
              TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 8),
              TextField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitude')),
              const SizedBox(height: 8),
              TextField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitude')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'published', child: Text('Published')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'draft'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _startController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Start Time'),
                onTap: () async {
                  final dt = await _pickDateTime(_startDateTime);
                  if (dt != null) {
                    setState(() {
                      _startDateTime = dt;
                      _startController.text = dt.toLocal().toString().split('.').first;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _endController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'End Time'),
                onTap: () async {
                  final dt = await _pickDateTime(_endDateTime ?? _startDateTime);
                  if (dt != null) {
                    setState(() {
                      _endDateTime = dt;
                      _endController.text = dt.toLocal().toString().split('.').first;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(onPressed: _pick, child: const Text('Pick Banner')),
                  const SizedBox(width: 12),
                  if (_image != null) Expanded(child: Text(_image!.name)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final res = await Navigator.push<LatLng>(
                        context,
                        MaterialPageRoute(builder: (_) => const MapPickerPage()),
                      );
                      if (res != null) {
                        setState(() {
                          _latController.text = res.latitude.toString();
                          _lngController.text = res.longitude.toString();
                        });
                      }
                    },
                    child: const Text('Pick on Map'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Lat: ${_latController.text}, Lng: ${_lngController.text}')),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: loading ? null : _save, child: loading ? const CircularProgressIndicator() : const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
