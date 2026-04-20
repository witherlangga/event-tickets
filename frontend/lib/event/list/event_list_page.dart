import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data event
    final events = [
      {'title': 'Music Concert', 'date': '2026-05-01'},
      {'title': 'Tech Conference', 'date': '2026-06-10'},
      {'title': 'Art Expo', 'date': '2026-07-20'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Event List')),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event['title']!),
            subtitle: Text('Date: ${event['date']}'),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/event-detail',
                arguments: {
                  'eventTitle': event['title'],
                  'eventDate': event['date'],
                },
              );
            },
          );
        },
      ),
    );
  }
}
