import 'package:conway/cell_position.dart';
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
    world = WorldState.fromFixture('''
........................
.xx....xx....xx....xx...
.xx....xx....xx....xx...
...xx....xx....xx....xx.
...xx....xx....xx....xx.
........................
........................
........................
........................
........................
''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text(widget.title))),
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                 child: ConwayGame(
                  world: world,
                  onToggle: (CellPosition position) {
                    setState(() {
                      world.toggle(position);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increementWorld,
        tooltip: 'NEXT',
        child: const Icon(Icons.directions_run),
      ),
    );
  }
}
