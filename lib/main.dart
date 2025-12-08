import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'ui/home/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. Creamos el AuthProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. Creamos el HomeProvider y le inyectamos el AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
          create: (_) => HomeProvider(), // Se crea vacío al inicio
          update: (_, auth, homeProvider) =>
              (homeProvider ?? HomeProvider())
                ..update(auth), // Se actualiza con el auth
        ),
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
