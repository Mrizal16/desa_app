import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const DesaSidorejoApp());
}

class DesaSidorejoApp
    extends StatelessWidget {
  const DesaSidorejoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Desa Sidorejo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              const Color(0xFF0284C7),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}