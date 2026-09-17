import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';
import 'providers/inventory_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/reports_provider.dart';
import 'views/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (Cloud Firestore & Auth with graceful local demo fallback)
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  final authService = AuthService();
  authService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: const MobileManagementApp(),
    ),
  );
}

class MobileManagementApp extends StatelessWidget {
  const MobileManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Mobile Zone Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const HomeShell(),
    );
  }
}
