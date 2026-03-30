import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device.model.dart';
import 'package:flutter_application_1/pages/add_device_page.dart';
import 'package:flutter_application_1/pages/edit_device.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/pages/registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? userEmail = prefs.getString('user_email');
  final bool isLoggedIn = userEmail != null && userEmail.isNotEmpty;

  runApp(SmartMeteoApp(isLoggedIn: isLoggedIn));
}

class SmartMeteoApp extends StatelessWidget {
  final bool isLoggedIn;
  const SmartMeteoApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Meteo Station',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B8FC)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/add_device': (context) => const AddDeviceScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit_device') {
          final device = settings.arguments as DeviceModel;
          return MaterialPageRoute(
            builder: (context) => EditDeviceScreen(device: device),
          );
        }
        return null;
      },
    );
  }
}
