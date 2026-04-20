import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final res = await AuthService().login(_email.text.trim(), _password.text.trim());
      if (!mounted) return;
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        final msg = res.data is Map && res.data.containsKey('message') ? res.data['message'] : res.data.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login gagal: $msg')));
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
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
          TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Register')),
        ]),
      ),
    );
  }
}
