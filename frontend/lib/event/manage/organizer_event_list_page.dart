import 'package:flutter/material.dart';
import '../../core/api_client.dart';

class OrganizerEventListPage extends StatefulWidget {
  const OrganizerEventListPage({super.key});

  @override
  State<OrganizerEventListPage> createState() => _OrganizerEventListPageState();
}

class _OrganizerEventListPageState extends State<OrganizerEventListPage> {
  List events = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final res = await ApiClient().dio.get('/organizer/events');
      setState(() => events = res.data is Map && res.data.containsKey('data') ? res.data['data'] : []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Events')),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/organizer/event-form').then((_) => _load()), child: const Icon(Icons.add)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, i) {
                final e = events[i];
                return ListTile(
                  title: Text(e['title'] ?? '-'),
                  subtitle: Text(e['status'] ?? '-'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(onPressed: () => Navigator.pushNamed(context, '/organizer/event-sales', arguments: {'event': e}).then((_) => _load()), icon: const Icon(Icons.bar_chart)),
                    IconButton(onPressed: () => Navigator.pushNamed(context, '/events/{eventId}/ticket-categories', arguments: {'eventId': e['id']}).then((_) => _load()), icon: const Icon(Icons.confirmation_number)),
                    IconButton(onPressed: () => Navigator.pushNamed(context, '/organizer/event-form', arguments: {'event': e}).then((_) => _load()), icon: const Icon(Icons.edit)),
                    IconButton(onPressed: () => ApiClient().dio.delete('/events/${e['id']}').then((_) => _load()), icon: const Icon(Icons.delete)),
                  ]),
                );
              },
            ),
    );
  }
}
