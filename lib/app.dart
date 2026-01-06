
import 'package:floradex/pages/floradex.dart';
import 'package:floradex/pages/scanner.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Floradex(),
    Scanner()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index){
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.filter_vintage_rounded), label: 'Floradex'),
          NavigationDestination(icon: Icon(Icons.filter_center_focus_rounded), label: 'Scanner')
        ]
      ),
    );
  }
}