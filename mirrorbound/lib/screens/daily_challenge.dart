import 'package:flutter/material.dart';
import 'package:mirrorbound/screens/game_screen.dart';
import 'package:mirrorbound/utils/constants.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenges')),
      body: ListView.builder(
        itemCount: Constants.dailyTrialCount,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('Challenge ${index + 1}'),
            subtitle: const Text('Complete within 20 moves'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(
                    levelId: 100 + index, // Special IDs for daily challenges
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}