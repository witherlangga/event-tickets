import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/backend_services.dart';
import '../manage/organizer_event_list_page.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List events = [];
  bool loading = true;
  String? role;

  @override
  void initState() {
    super.initState();
    _fetch();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await ProfileService().getProfile();
      final raw = res.data;
      final data = raw is Map && raw.containsKey('data') ? raw['data'] : raw;
      // try several common keys for role
      String? detected;
      if (data is Map) {
        detected = data['role']?.toString();
        detected ??= data['type']?.toString();
        detected ??= data['user'] is Map ? data['user']['role']?.toString() : null;
        detected ??= raw['role']?.toString();
      }
      // debug prints
      // ignore: avoid_print
      print('[EventList] profile raw=$raw detectedRole=$detected');
      setState(() => role = detected);
    } catch (_) {}
  }

  Future<void> _fetch() async {
    setState(() => loading = true);
    try {
      final res = await EventService().getEvents();
      final data = res.data;
      setState(() => events = data is Map && data.containsKey('data') ? data['data'] : []);
      // quick debug log
      // ignore: avoid_print
      print('[EventList] fetched events count=${events.length}');
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      int? code;
      dynamic body;
      if (e is DioException) {
        code = e.response?.statusCode;
        body = e.response?.data;
        msg = 'HTTP ${code ?? '??'} - ${body ?? e.message}';
      }
      // show detailed snackbar to help debug
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat events: $msg')));
      // also print to console
      // ignore: avoid_print
      print('[EventList] fetch error: $msg');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events'), actions: [
        if (role == 'organizer') IconButton(onPressed: () => Navigator.pushNamed(context, '/organizer/events').then((_) => _fetch()), icon: const Icon(Icons.manage_accounts))
      ]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: events.isEmpty
                  ? ListView(
                      // to enable pull-to-refresh on empty
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Tidak ada event tersedia', style: TextStyle(fontSize: 16))),
                      ],
                    )
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, i) {
                        final e = events[i];
                        return ListTile(
                          title: Text(e['title'] ?? '-'),
                          subtitle: Text(e['start_time'] ?? '-'),
                          onTap: () => Navigator.pushNamed(context, '/event-detail', arguments: {'eventId': e['id'], 'eventTitle': e['title'], 'eventDate': e['start_time']}),
                        );
                      },
                    ),
            ),
    );
  }
}
