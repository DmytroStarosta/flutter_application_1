import 'package:flutter/material.dart';

import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/logic/cubits/auth_cubit.dart';
import 'package:flutter_application_1/logic/cubits/device_cubit.dart';

import 'package:flutter_application_1/pages/add_device_page.dart';
import 'package:flutter_application_1/pages/edit_device.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:flutter_application_1/pages/profile_page.dart';
import 'package:flutter_application_1/pages/registration_page.dart';

import 'package:flutter_application_1/widgets/check_connection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  
  final String? userEmail = prefs.getString('user_email');
  final bool isLoggedIn = userEmail != null && userEmail.isNotEmpty;

  final authCubit = AuthCubit();
  
  if (isLoggedIn) {
    await authCubit.syncUserData();
  }

  runApp(SmartMeteoApp(
    isLoggedIn: isLoggedIn, 
    authCubit: authCubit,
  ));
}

class SmartMeteoApp extends StatelessWidget {
  final bool isLoggedIn;
  final AuthCubit authCubit;

  const SmartMeteoApp({
    required this.isLoggedIn, 
    required this.authCubit, 
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(
          value: authCubit,
        ),
        BlocProvider<DeviceCubit>(
          create: (context) => DeviceCubit()..loadDevices(),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Meteo Station',
        debugShowCheckedModeBanner: false,
        
        builder: (context, child) {
          return CheckConnection(child: child ?? const SizedBox());
        },
        
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00B8FC)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
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
      ),
    );
  }
}
