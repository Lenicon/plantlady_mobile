import 'package:flutter/material.dart';

class Floradex extends StatefulWidget {
  const Floradex({super.key});

  @override
  State<Floradex> createState() => _FloradexState();
}

class _FloradexState extends State<Floradex> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: Column(
        children: [
          
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Floradex',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      backgroundColor: Colors.pink.shade100,
      elevation: 2.0,
      shadowColor: Colors.pink,
    );
  }
}