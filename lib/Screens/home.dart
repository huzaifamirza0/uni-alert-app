import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}
