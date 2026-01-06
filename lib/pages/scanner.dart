import 'package:flutter/material.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Plant Scanner',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      // backgroundColor: Color.fromARGB(255, 247, 220, 238),
      elevation: 0.0,
      // shadowColor: Colors.pink,
    );
  }
}