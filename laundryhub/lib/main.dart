import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/landing/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/test_dashboard.dart';

import 'screens/transaction/transaction_screen.dart';

import 'customer_screen/customer_dashboard_screen.dart';
import 'customer_screen/customer_home_screen.dart';
import 'customer_screen/customer_profile_screen.dart';
import 'customer_screen/customer_transaction_screen.dart';

void main() {
  runApp(const LaundryHub());
}

class LaundryHub extends StatelessWidget {
  const LaundryHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LaundryHub',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        primaryColor: const Color(0xFF2563EB),

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF2563EB),
          surface: Colors.white,
        ),

        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Color(0x11000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),

        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
          ),
        ),

        textTheme: GoogleFonts.poppinsTextTheme(),
      ),

      initialRoute: '/',

      routes: {
        // Landing
        '/': (context) => const LandingScreen(),

        // Auth
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),

        // Owner
        '/dashboard': (context) => const DashboardScreen(),
        '/transactions': (context) => TransactionScreen(),
        '/test-dashboard': (context) => const TestDashboard(),

        // Customer
        '/customer-dashboard': (context) =>
            const CustomerDashboardScreen(),

        '/customer-home': (context) =>
            const CustomerHomeScreen(),

        '/customer-profile': (context) =>
            const CustomerProfileScreen(),

        '/customer-transactions': (context) =>
            const CustomerTransactionScreen(),
      },
    );
  }
}