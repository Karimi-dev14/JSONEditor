import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/json_editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1080, 720),
    minimumSize: Size(1000, 600), 
    title: 'JSON Editor',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Editor',
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
