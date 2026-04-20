import 'package:flutter/material.dart';
import '../../core/backend_services.dart';
import '../../core/api_client.dart';
import '../../event/manage/ticket_category_form_page.dart';

class TicketCategoryListPage extends StatefulWidget {
  const TicketCategoryListPage({super.key});

  @override
  State<TicketCategoryListPage> createState() => _TicketCategoryListPageState();
}

class _TicketCategoryListPageState extends State<TicketCategoryListPage> {
  List categories = [];
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final eventId = args?['eventId'];
    if (eventId != null) _load(eventId);
  }

  Future<void> _load(int eventId) async {
    setState(() => loading = true);
    try {
      final res = await TicketCategoryService().getTicketCategories(eventId);
      setState(() => categories = res.data is Map && res.data.containsKey('data') ? res.data['data'] : []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat kategori')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Categories'), actions: [
        Builder(builder: (ctx) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final eventId = args?['eventId'];
          if (eventId == null) return const SizedBox.shrink();
          return PopupMenuButton<String>(onSelected: (v) async {
            if (v == 'reguler' || v == 'vip') {
              final preset = v == 'reguler'
                  ? {'name': 'Reguler', 'price': 50000, 'quota': 100}
                  : {'name': 'VIP', 'price': 200000, 'quota': 50};
              final created = await Navigator.push(ctx, MaterialPageRoute(builder: (_) => TicketCategoryFormPage(eventId: eventId, initial: preset)));
              if (created == true) _load(eventId);
            }
          }, itemBuilder: (_) => const [
                PopupMenuItem(value: 'reguler', child: Text('Tambah Reguler')),
                PopupMenuItem(value: 'vip', child: Text('Tambah VIP')),
              ]);
        }),
      ]),
      floatingActionButton: Builder(builder: (ctx) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final eventId = args?['eventId'];
        if (eventId == null) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () async {
            final created = await Navigator.push(ctx, MaterialPageRoute(builder: (_) => TicketCategoryFormPage(eventId: eventId)));
            if (created == true) _load(eventId);
          },
          child: const Icon(Icons.add),
        );
      }),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final c = categories[i];
                final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                final eventId = args?['eventId'];
                return ListTile(
                  title: Text(c['name'] ?? '-'),
                  subtitle: Text('Rp ${c['price']}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: eventId == null
                          ? null
                          : () async {
                              final edited = await Navigator.push(context, MaterialPageRoute(builder: (_) => TicketCategoryFormPage(eventId: eventId, initial: c)));
                              if (edited == true && eventId != null) _load(eventId);
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: eventId == null
                          ? null
                          : () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Hapus kategori'),
                                  content: const Text('Yakin hapus kategori tiket ini?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
                                    TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Hapus')),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                try {
                                  await ApiClient().dio.delete('/organizer/events/$eventId/ticket-categories/${c['id']}');
                                  if (eventId != null) _load(eventId);
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghapus')));
                                }
                              }
                            },
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
