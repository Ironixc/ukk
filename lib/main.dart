import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ukk/providers/admin_provider.dart';
import 'package:ukk/providers/booking_provider.dart';
import 'package:ukk/screens/auth/register_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()), // Tambahkan ini
        ChangeNotifierProvider(create: (_) => BookingProvider()),

      ],
      child: MaterialApp(
        title: 'KAI App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Color(0xFF2D3E50),
          fontFamily: 'GoogleFonts.poppins().fontFamily', // Gunakan font modern
        ),
        home: LoginScreen(),
      ),
    );
  }
}