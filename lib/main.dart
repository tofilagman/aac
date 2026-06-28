import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/aac_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AacProvider(),
      child: const AacApp(),
    ),
  );
}

class AacApp extends StatelessWidget {
  const AacApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAC Board',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
