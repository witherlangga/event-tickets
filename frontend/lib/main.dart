                    '/transaction-detail': (context) {
                      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                      return TransactionDetailPage(
                        id: args?['id'] ?? '-',
                        event: args?['event'] ?? '-',
                        date: args?['date'] ?? '-',
                        total: args?['total'] ?? 0,
                      );
                    },
            '/qr-scanner': (context) => const QrScannerPage(),
          '/profile-edit': (context) => const ProfileEditPage(),
        '/ticket-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return TicketDetailPage(
            event: args?['event'] ?? '-',
            date: args?['date'] ?? '-',
            code: args?['code'] ?? '-',
          );
        },
import 'package:flutter/material.dart';
import 'auth/login/login_page.dart';
import 'auth/register/register_page.dart';
import 'event/list/event_list_page.dart';
import 'event/detail/event_detail_page.dart';
import 'main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Tickets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainNavigation(),
        '/events': (context) => const EventListPage(),
        '/event-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return EventDetailPage(
            eventTitle: args?['eventTitle'] ?? 'Event',
            eventDate: args?['eventDate'] ?? '2026-01-01',
          );
        },
      },
    );
  }
}

// ...existing code...
