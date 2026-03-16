import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/registration_page.dart';

void main() {
  runApp(const SmartMeteoApp());
}

class SmartMeteoApp extends StatelessWidget {
  const SmartMeteoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Meteo Station',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), 
        '/home': (context) => const LoginScreen(),
        '/profile': (context) => const LoginScreen(),
      },
    );
  }
}