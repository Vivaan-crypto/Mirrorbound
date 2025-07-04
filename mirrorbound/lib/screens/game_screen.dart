import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:mirrorbound/game/mirrorbound_game.dart';

class GameScreen extends StatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MirrorBoundGame game;
  bool showTutorial = true;

  @override
  void initState() {
    super.initState();
    game = MirrorBoundGame(widget.levelId);

    // Hide tutorial after delay
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => showTutorial = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          if (showTutorial && widget.levelId <= 3)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getTutorialText(widget.levelId),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => game.undoSystem.undo(
          player: game.player,
          physics: game.physics,
        ),
        child: const Icon(Icons.undo),
      ),
    );
  }

  String _getTutorialText(int level) {
    switch (level) {
      case 1:
        return 'Tap mirrors to split the world';
      case 2:
        return 'Swipe down to invert gravity';
      case 3:
        return 'Combine both mechanics to solve puzzles';
      default:
        return '';
    }
  }
}