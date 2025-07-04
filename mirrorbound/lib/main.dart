import 'package:flutter/material.dart';
import 'package:mirrorbound/screens/menu_screen.dart';
import 'package:mirrorbound/utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initStorage(); // Removed initHive
  runApp(const MirrorBoundApp());
}

class MirrorBoundApp extends StatelessWidget {
  const MirrorBoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirrorbound',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const MenuScreen(),
    );
  }
}