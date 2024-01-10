import 'package:apng_resize/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ApngResizeApp(),
    ),
  );
}

class ApngResizeApp extends StatelessWidget {
  const ApngResizeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APNG Resize',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
