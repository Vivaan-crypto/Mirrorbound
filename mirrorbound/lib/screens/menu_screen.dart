import 'package:flutter/material.dart';
import 'package:mirrorbound/screens/level_select.dart';
import 'package:mirrorbound/screens/daily_challenge.dart';
import 'package:mirrorbound/screens/shop_screen.dart';
import 'package:mirrorbound/utils/constants.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A8EAE),
              Color(0xFF9B5DE5),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Mirrorbound',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 50),
              _buildButton('Start Game', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LevelSelectScreen(),
                  ),
                );
              }),
              _buildButton('Daily Challenges', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyChallengeScreen(),
                  ),
                );
              }),
              _buildButton('Cosmetic Shop', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShopScreen(),
                  ),
                );
              }),
              _buildButton('Settings', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}