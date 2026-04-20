import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/backend_services.dart';
import '../core/api_client.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _avatar = TextEditingController();
  XFile? _pickedImage;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await ProfileService().getProfile();
      final raw = res.data;
      final data = raw is Map && raw.containsKey('data') ? raw['data'] : (raw['user'] ?? raw);
      _name.text = data['name'] ?? '';
      _phone.text = data['phone'] ?? '';
      _email.text = data['email'] ?? '';
      _avatar.text = data['avatar'] ?? '';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => loading = true);
    try {
      dynamic data;
      if (_pickedImage != null) {
        MultipartFile filePart;
        if (kIsWeb) {
          final bytes = await _pickedImage!.readAsBytes();
          filePart = MultipartFile.fromBytes(bytes, filename: _pickedImage!.name);
        } else {
          filePart = await MultipartFile.fromFile(_pickedImage!.path, filename: _pickedImage!.name);
        }
        data = FormData.fromMap({
          'name': _name.text,
          'phone': _phone.text,
          'email': _email.text,
          'avatar': filePart,
        });
        await ApiClient().dio.put('/profile', data: data);
      } else {
        await ProfileService().updateProfile({'name': _name.text, 'phone': _phone.text, 'email': _email.text, 'avatar': _avatar.text});
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null) setState(() => _pickedImage = f);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
                Row(children: [
                  Expanded(child: TextField(controller: _avatar, decoration: const InputDecoration(labelText: 'Avatar URL'))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _pickImage, child: const Text('Upload')),
                ]),
                if (_pickedImage != null) Padding(padding: const EdgeInsets.only(top:8.0), child: Text('Picked: ${_pickedImage!.name}')),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _save, child: const Text('Save')),
              ]),
            ),
    );
  }
}
