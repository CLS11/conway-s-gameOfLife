import 'package:conway/conway.dart';
import 'package:conway/conway_game.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.title, super.key});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WorldState world;

  void _increementWorld() {
    setState(() {
      world = next(world)!;
    });
  }

  @override
  void initState() {
    super.initState();
    world = WorldState.fromString('''
......
.xx...
.xx...
...xx.
...xx.
......
''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text(widget.title))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ConwayGame(
              world: world,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increementWorld,
        tooltip: 'NEXT',
        child: const Icon(Icons.directions_run),
      ),
    );
  }
}
