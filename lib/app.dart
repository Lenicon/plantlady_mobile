
import 'package:daisiedex/pages/florilegium.dart';
import 'package:daisiedex/pages/identifier.dart';
import 'package:daisiedex/services/storage_service.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Florilegium(),
    Identifier()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        shadowColor: Colors.black,
        elevation: 20.0,
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index){
          
          if (index == 1) {
            StorageService.load();
          }
          
          setState(() {
            _currentIndex = index;
          });

        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.filter_vintage_rounded), label: 'Florilegium'),
          NavigationDestination(icon: Icon(Icons.filter_center_focus_rounded), label: 'Identifier')
        ]
      ),
    );
  }
  
}