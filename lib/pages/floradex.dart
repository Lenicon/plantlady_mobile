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
      appBar: AppBar(
        title: Text(
          'Floradex',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
    );
  }
}