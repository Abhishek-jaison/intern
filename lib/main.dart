import 'package:flutter/material.dart';
import 'screens/freight_search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freight Rates Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          background: const Color.fromRGBO(230, 234, 248, 1),
        ),
        useMaterial3: true,
      ),
      home: const FreightSearchScreen(),
    );
  }
}
