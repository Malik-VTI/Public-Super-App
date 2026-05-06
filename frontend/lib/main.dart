import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/document/document_list_screen.dart';
import 'presentation/screens/document/document_form_screen.dart';
import 'presentation/screens/payment/tax_list_screen.dart';
import 'presentation/screens/payment/payment_form_screen.dart';
import 'presentation/screens/payment/payment_status_screen.dart';
import 'presentation/screens/complaint/complaint_list_screen.dart';
import 'presentation/screens/complaint/complaint_form_screen.dart';

void main() {
  runApp(const GovApp());
}

class GovApp extends StatelessWidget {
  const GovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GovApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/documents': (context) => const DocumentListScreen(),
        '/documents/create': (context) => const DocumentFormScreen(),
        '/payments': (context) => const TaxListScreen(),
        '/payments/process': (context) => const PaymentFormScreen(),
        '/payments/status': (context) => const PaymentStatusScreen(),
        '/payments/history': (context) => const TaxListScreen(), // reuse for demo
        '/complaints': (context) => const ComplaintListScreen(),
        '/complaints/create': (context) => const ComplaintFormScreen(),
      },
    );
  }
}
