import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importaciones de tus archivos propios
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'ui/auth/login_screen.dart';
import 'ui/home/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniEmprende',
      // Quitamos el banner de "DEBUG" en la esquina
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
