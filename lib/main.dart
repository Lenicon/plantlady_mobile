import 'package:floradex/app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Zain',
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromARGB(255, 245, 159, 216),
          onPrimary: Colors.black,
          secondary: Color.fromARGB(255, 243, 193, 226),
          onSecondary: Colors.black,
          error: Colors.red.shade200,
          onError: Colors.red.shade400,
          surface: Color.fromARGB(255, 247, 220, 238),
          onSurface: Colors.black
        )
      ),
      home: App(),
    );
  }
}
