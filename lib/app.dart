import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/two_factor/presentation/screens/home_screen.dart';

class CedarApp extends StatelessWidget {
  const CedarApp({super.key});

  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      title: 'Cedar 2FA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D5B),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}