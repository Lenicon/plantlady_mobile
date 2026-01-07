import 'package:floradex/app.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: snackbarKey,
      debugShowCheckedModeBanner: false,
      theme: pinkTheme(),
      home: App(),
    );
  }

  ThemeData pinkTheme() {
    return ThemeData(
      // textTheme: TextTheme(
      //   bodyMedium: TextStyle(height: 5), // Increase height to shift text down
      //   displayLarge: TextStyle(height: 2),
      // ),
      fontFamily: 'Zain',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Color.fromARGB(255, 255, 121, 233),
        onPrimary: Colors.black,
        secondary: Color.fromARGB(255, 255, 143, 218),
        onSecondary: Colors.black,
        error: Colors.red.shade200,
        onError: Colors.red.shade400,
        surface: Color.fromARGB(255, 255, 197, 236),
        onSurface: Colors.black
      )
    );
  }
}
