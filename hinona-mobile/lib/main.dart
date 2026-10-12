import 'package:flutter/material.dart';
import 'package:hinona_mobile/screens/home/home_screen.dart'; // <-- Gunakan path lengkap package ini

void main() {
  runApp(const HinonaApp());
}

class HinonaApp extends StatelessWidget {
  const HinonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hinona Coffee & Roastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
      ),
      home: HomeScreen(),
    );
  }
}