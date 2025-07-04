import 'package:flutter/material.dart';
import 'package:mirrorbound/screens/game_screen.dart';
import 'package:mirrorbound/utils/storage.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  int unlockedLevels = 10;
  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final levels = await getUnlockedLevels();
    setState(() {
      unlockedLevels = levels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 30,
        itemBuilder: (context, index) {
          final levelNumber = index + 1;
          final isUnlocked = levelNumber <= unlockedLevels;

          return GestureDetector(
            onTap: isUnlocked
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(levelId: levelNumber),
                ),
              );
            }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$levelNumber',
                  style: TextStyle(
                    fontSize: 24,
                    color: isUnlocked ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}