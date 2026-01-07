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
          searchField(),
        ],
      ),
    );
  }


  // BUILDER FUNCTIONS
  Container searchField() {
    return Container(
          margin: EdgeInsets.only(top: 30, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(
              color: Color.fromARGB(12, 29, 22, 23),
              blurRadius: 40,
              spreadRadius: 0.0
            )]
          ),
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              hintText: 'Search discovered plant...',
              hintStyle: TextStyle(
                color: Colors.black54,
                fontSize: 18,
              ),
              // fillColor: Color.fromARGB(255, 247, 220, 238),
              contentPadding: EdgeInsets.all(15),
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            ),
          ),
        );
  }

  AppBar appBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Collections',
        style: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      // backgroundColor: Color.fromARGB(255, 247, 220, 238),
      elevation: 0.0,
      // shadowColor: Colors.pink,
    );
  }
}