import 'package:conway/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(Conway());
}

class Conway extends StatelessWidget {
  const Conway({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(
        title: 'H O M E    P A G E',
      ),
    );
  }
}
