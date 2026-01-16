import 'package:daisiedex/app.dart';
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
    // Pink: 0xFFFFB3BA
    // Red: 0xFFC62828
    // Yellow: #FFFDE06C

    // Searchbar: 0xFFF0DEDE
    // Icon: 0xFF524444
    
    // NavBar BG: 0xFFFCEAEA
    // Navbar Button: 0xFFFEDADC
    // onNavbar: 0xFF514343
    // onNavbarFocus: 0xFF2B1517

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Zain',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFB3BA),
        primary: const Color(0xFFFFB3BA),
        secondary: const Color(0xFFFCEAEA),
        // tertiary: const Color.fromARGB(255, 215, 0, 108),
        surface: const Color(0xFFFFF8F8),
        // surface: const Color.fromARGB(255, 239, 2, 2),
        error: const Color(0xFFC62828),
        onPrimary: Colors.black54,
        onSecondary: Color(0xFF514343),
        onError: Colors.white,
      ),
      
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFB3BA),
        foregroundColor: Colors.black,
        elevation: 0,
        titleTextStyle: TextStyle(fontFamily: 'Zain', color:Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        centerTitle: true,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFB3BA),
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey,
          disabledForegroundColor: Colors.white,
          animationDuration: Duration.zero,
          shadowColor: Colors.transparent
        ),
        
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF514343)),
          foregroundColor: Color(0xFF514343),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFDE06C),
        foregroundColor: Colors.black,
      ),

      // scaffoldBackgroundColor: Color(0xFFFFF8F8),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFFCEAEA)
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Color(0xFFFFF8F8)
      )

      // navigationBarTheme: const NavigationBarThemeData(
      //   backgroundColor: Color(0xFFFFB3BA)
      // )
      
    );
  }

}
