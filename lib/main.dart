import 'package:flutter/material.dart';
import 'screens/json_editor_screen.dart';

void main() {
  runApp(const JsonEditorApp());
}

class JsonEditorApp extends StatelessWidget {
  const JsonEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Editor & Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: Colors.blueAccent,
        cardColor: const Color(0xFF252526),
      ),
      home: const JsonEditorScreen(),
    );
  }
}