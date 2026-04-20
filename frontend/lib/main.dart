import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'main_navigation.dart';
import 'event/list/event_list_page.dart';
import 'event/detail/event_detail_page.dart';
import 'event/manage/organizer_event_list_page.dart';
import 'event/manage/organizer_sales_page.dart';
import 'event/manage/event_form_page.dart';
import 'event/manage/map_picker_page.dart';
import 'ticket/categories/ticket_category_list_page.dart';
import 'booking/booking_page.dart';
import 'booking/my_tickets_page.dart';
import 'booking/ticket_detail_page.dart';
import 'checkin/checkin_page.dart';
import 'profile/profile_page.dart';
import 'profile/profile_edit_page.dart';
import 'transaction/transactions_page.dart';
import 'transaction/transaction_detail_page.dart';
import 'admin/admin_dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Tickets',
      debugShowCheckedModeBanner: false,
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
            eventId: args?['eventId'],
            eventTitle: args?['eventTitle'] ?? 'Event',
            eventDate: args?['eventDate'] ?? '2026-01-01',
          );
        },
        '/organizer/events': (context) => const OrganizerEventListPage(),
        '/organizer/event-form': (context) => const EventFormPage(),
        '/organizer/event-sales': (context) => const OrganizerSalesPage(),
        '/organizer/map-picker': (context) => const MapPickerPage(),
        '/events/{eventId}/ticket-categories': (context) => const TicketCategoryListPage(),
        '/booking': (context) => const BookingPage(),
        '/my-tickets': (context) => const MyTicketsPage(),
        '/ticket-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return TicketDetailPage(ticketId: args?['id']);
        },
        '/checkin': (context) => const CheckInPage(),
        '/profile': (context) => const ProfilePage(),
        '/profile/edit': (context) => const ProfileEditPage(),
        '/transactions': (context) => const TransactionsPage(),
        '/transaction-detail': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return TransactionDetailPage(id: args?['id']);
        },
        '/admin': (context) => const AdminDashboardPage(),
      },
    );
  }
}

// ...existing code...
