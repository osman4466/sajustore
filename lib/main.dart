import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SajuConfectioneryApp());
}

class SajuConfectioneryApp extends StatelessWidget {
  const SajuConfectioneryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
