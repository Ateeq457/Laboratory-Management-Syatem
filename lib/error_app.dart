import 'package:flutter/material.dart';

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            "App failed to start ❌",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
