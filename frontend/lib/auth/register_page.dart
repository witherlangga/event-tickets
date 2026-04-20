import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _organizationName = TextEditingController();
  final _address = TextEditingController();
  final _contactPerson = TextEditingController();
  final _contactPhone = TextEditingController();
  String _role = 'customer';
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final body = {
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'password': _password.text.trim(),
        'role': _role,
        if (_role == 'organizer') 'organization_name': _organizationName.text.trim(),
        if (_role == 'organizer') 'address': _address.text.trim(),
        if (_role == 'organizer') 'contact_person': _contactPerson.text.trim(),
        if (_role == 'organizer') 'contact_phone': _contactPhone.text.trim(),
      };
      final res = await AuthService().register(body);
      if (!mounted) return;
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        final msg = res.data is Map && res.data.containsKey('message') ? res.data['message'] : res.data.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register gagal: $msg')));
      }
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      if (e is DioException && e.response != null) {
        msg = e.response?.data?.toString() ?? e.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $msg')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
          TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 8),
          DropdownButton<String>(value: _role, items: const [
            DropdownMenuItem(value: 'customer', child: Text('Customer')),
            DropdownMenuItem(value: 'organizer', child: Text('Organizer')),
          ], onChanged: (v) => setState(() => _role = v ?? 'customer')),
          const SizedBox(height: 12),
          if (_role == 'organizer') ...[
            TextField(controller: _organizationName, decoration: const InputDecoration(labelText: 'Organization Name')),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            TextField(controller: _contactPerson, decoration: const InputDecoration(labelText: 'Contact Person')),
            TextField(controller: _contactPhone, decoration: const InputDecoration(labelText: 'Contact Phone')),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Register')),
        ]),
      ),
    );
  }
}
