import 'package:flutter/material.dart';
import 'package:sport_application/screens/login_screen_new.dart';
import 'package:sport_application/screens/main_screen.dart';
import 'package:sport_application/services/supabase_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreenNew(),
      }, // Handle dynamic routes with parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/main') {
          // Extract arguments if provided
          int initialTab = 0;
          String? bookingId;

          if (settings.arguments is int) {
            initialTab = settings.arguments as int;
          } else if (settings.arguments is Map) {
            final args = settings.arguments as Map;
            initialTab = args['initialTab'] as int? ?? 0;
            bookingId = args['bookingId'] as String?;
          }

          return MaterialPageRoute(
            builder:
                (context) => MainScreen(
                  initialTab: initialTab,
                  highlightBookingId: bookingId,
                ),
          );
        }
        return null;
      },
    );
  }
}
