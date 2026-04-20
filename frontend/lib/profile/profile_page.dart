import 'package:flutter/material.dart';
import '../core/backend_services.dart';
import '../core/api_client.dart';
import '../auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map? profile;
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
      setState(() => profile = res.data['data'] ?? res.data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat profile')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (profile?['avatar'] != null && profile!['avatar'] != '')
                  Builder(builder: (ctx) {
                    final raw = profile!['avatar'].toString();
                    final src = ApiClient.resolveAssetUrl(raw);
                    return Center(child: Image.network(src, height: 80, width: 80));
                  }),
                Text('Name: ${profile?['name'] ?? '-'}'),
                Text('Email: ${profile?['email'] ?? '-'}'),
                Text('Phone: ${profile?['phone'] ?? '-'}'),
                const SizedBox(height: 8),
                if (profile != null && profile!['organizer'] != null) ...[
                  const Text('Organizer Profile:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Organization: ${profile!['organizer']['organization_name'] ?? '-'}'),
                  Text('Address: ${profile!['organizer']['address'] ?? '-'}'),
                  Text('Contact: ${profile!['organizer']['contact_person'] ?? '-'}'),
                  Text('Contact Phone: ${profile!['organizer']['contact_phone'] ?? '-'}'),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/profile/edit').then((_) => _load()), child: const Text('Edit Profile')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/transactions'), child: const Text('Riwayat Pembelian')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () async {
                    await AuthService().logout();
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  }, child: const Text('Logout')),
                ]),
              ]),
            ),
    );
  }
}
