import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';
import 'audio_manager.dart';

void main() {
  runApp(MirrorboundApp());
}

class MirrorboundApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirrorbound: Fractured Reflections',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Quicksand',
      ),
      home: MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _particleController;
  late Animation<double> _titleAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    AudioManager.instance.initAudio();

    _titleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _titleController.forward();
    _particleController.repeat();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF1A0F3A),
              Color(0xFF0A0620),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  AnimatedBuilder(
                    animation: _titleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _titleAnimation.value,
                        child: Opacity(
                          opacity: _titleAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                'MIRRORBOUND',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Color(0xFFFF6B9D),
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Fractured Reflections',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFB794F6),
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 80),

                  // Play Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AudioManager.instance.playChime();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF6B9D),
                            Color(0xFFFF8A65),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF6B9D).withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        'START JOURNEY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Settings Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      AudioManager.instance.playChime();
                      _showSettings(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFB794F6), width: 2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB794F6),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A0F3A),
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Sound Effects', style: TextStyle(color: Colors.white)),
              value: AudioManager.instance.soundEnabled,
              onChanged: (value) {
                AudioManager.instance.toggleSound();
                setState(() {});
              },
              activeColor: Color(0xFFFF6B9D),
            ),
            SwitchListTile(
              title: Text('Haptic Feedback', style: TextStyle(color: Colors.white)),
              value: AudioManager.instance.hapticEnabled,
              onChanged: (value) {
                AudioManager.instance.toggleHaptic();
                setState(() {});
              },
              activeColor: Color(0xFFFF6B9D),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Color(0xFFFF6B9D))),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFFF6B9D).withOpacity(0.3)
      ..blendMode = BlendMode.plus;

    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0 + animationValue * 100) % size.width;
      final y = (i * 30.0 + animationValue * 80) % size.height;
      final radius = (i % 3 + 1) * 2.0;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}