import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ludyo/auth/firebase_auth.dart';
import 'package:ludyo/pages/main_page.dart';
import 'package:ludyo/themes/app_theme.dart';
import 'package:ludyo/utils/no_over_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await authService.value.initialize();

  await Hive.initFlutter();
  await Hive.openBox('ApiCache');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      scrollBehavior: NoOverScrollBehavior(),
      home: const MainPage(),
    );
  }
}
