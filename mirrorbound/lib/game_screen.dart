//import 'mirror_physics.dart';
import 'level_manager.dart';
import 'audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;



class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late MirrorPhysics _physics;
  late LevelManager _levelManager;
  late AnimationController _transitionController;
  late AnimationController _mirrorController;
  late Animation<double> _mirrorAnimation;

  int _currentLevel = 0;
  int _moves = 0;
  bool _isLevelComplete = false;
  bool _showMirror = false;

  @override
  void initState() {
    super.initState();
    _physics = MirrorPhysics();
    _levelManager = LevelManager();

    _transitionController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _mirrorController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _mirrorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mirrorController,
      curve: Curves.easeInOut,
    ));

    _loadLevel();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _mirrorController.dispose();
    super.dispose();
  }

  void _loadLevel() {
    final level = _levelManager.getLevel(_currentLevel);
    _physics.loadLevel(level);
    _moves = 0;
    _isLevelComplete = false;
    _showMirror = false;
    _mirrorController.reset();
    setState(() {});
  }

  void _toggleMirror() {
    setState(() {
      _showMirror = !_showMirror;
      if (_showMirror) {
        _mirrorController.forward();
      } else {
        _mirrorController.reverse();
      }
    });

    AudioManager.instance.playChime();
    HapticFeedback.lightImpact();
  }

  void _movePlayer(Direction direction) {
    if (_isLevelComplete) return;

    _moves++;
    bool success = _physics.movePlayer(direction);

    if (success) {
      AudioManager.instance.playChime();
      HapticFeedback.selectionClick();

      if (_physics.isLevelComplete()) {
        _isLevelComplete = true;
        AudioManager.instance.playChime();
        HapticFeedback.heavyImpact();
        _showLevelComplete();
      }
    } else {
      AudioManager.instance.playError();
      HapticFeedback.lightImpact();
    }

    setState(() {});
  }

  void _showLevelComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A0F3A),
        title: Text(
          'Level Complete!',
          style: TextStyle(
            color: Color(0xFFFF6B9D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Moves: $_moves',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => Icon(
                  Icons.star,
                  color: _moves <= (3 - index) * 5
                      ? Color(0xFFFFD700)
                      : Colors.grey,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextLevel();
            },
            child: Text(
              'Next Level',
              style: TextStyle(color: Color(0xFFFF6B9D)),
            ),
          ),
        ],
      ),
    );
  }

  void _nextLevel() {
    _currentLevel++;
    if (_currentLevel >= _levelManager.totalLevels) {
      _currentLevel = 0; // Loop back to start
    }
    _loadLevel();
  }

  void _resetLevel() {
    _loadLevel();
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
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFF1A0F3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Text(
                      'Level ${_currentLevel + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Moves: $_moves',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Game Area
              Expanded(
                child: Stack(
                  children: [
                    // Real World
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPaint(
                        painter: GamePainter(
                          _physics,
                          false,
                          _mirrorAnimation.value,
                        ),
                      ),
                    ),

                    // Mirror World
                    if (_showMirror)
                      AnimatedBuilder(
                        animation: _mirrorAnimation,
                        builder: (context, child) {
                          return ClipRect(
                            child: Transform.scale(
                              scaleX: _mirrorAnimation.value,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: CustomPaint(
                                  painter: GamePainter(
                                    _physics,
                                    true,
                                    _mirrorAnimation.value,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Controls
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Mirror Toggle
                    GestureDetector(
                      onTap: _toggleMirror,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF6B9D),
                              Color(0xFFFF8A65),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6B9D).withOpacity(0.3),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          _showMirror ? 'CLOSE MIRROR' : 'OPEN MIRROR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // Movement Controls
                    Column(
                      children: [
                        // Up
                        GestureDetector(
                          onTap: () => _movePlayer(Direction.up),
                          child: _buildControlButton(Icons.keyboard_arrow_up),
                        ),

                        SizedBox(height: 10),

                        // Left, Down, Right
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () => _movePlayer(Direction.left),
                              child: _buildControlButton(Icons.keyboard_arrow_left),
                            ),
                            GestureDetector(
                              onTap: () => _movePlayer(Direction.down),
                              child: _buildControlButton(Icons.keyboard_arrow_down),
                            ),
                            GestureDetector(
                              onTap: () => _movePlayer(Direction.right),
                              child: _buildControlButton(Icons.keyboard_arrow_right),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Reset Button
                    GestureDetector(
                      onTap: _resetLevel,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'RESET',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
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
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white54),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final MirrorPhysics physics;
  final bool isMirror;
  final double mirrorOpacity;

  GamePainter(this.physics, this.isMirror, this.mirrorOpacity);

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = 40.0;
    final level = physics.currentLevel;

    // Background
    final bgPaint = Paint()
      ..color = isMirror
          ? Color(0xFFFF6B9D).withOpacity(0.1 * mirrorOpacity)
          : Color(0xFF667EEA).withOpacity(0.1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid
    final gridPaint = Paint()
      ..color = (isMirror ? Color(0xFFFF8A65) : Color(0xFFB794F6))
          .withOpacity(0.3 * (isMirror ? mirrorOpacity : 1.0))
      ..strokeWidth = 1;

    for (int x = 0; x < size.width; x += gridSize.toInt()) {
      canvas.drawLine(
        Offset(x.toDouble(), 0),
        Offset(x.toDouble(), size.height),
        gridPaint,
      );
    }

    for (int y = 0; y < size.height; y += gridSize.toInt()) {
      canvas.drawLine(
        Offset(0, y.toDouble()),
        Offset(size.width, y.toDouble()),
        gridPaint,
      );
    }

    // Platforms
    final platformPaint = Paint()
      ..color = (isMirror ? Color(0xFFFF6B9D) : Color(0xFF4C1D95))
          .withOpacity(isMirror ? mirrorOpacity : 1.0);

    for (var platform in level.platforms) {
      var rect = Rect.fromLTWH(
        platform.x * gridSize,
        platform.y * gridSize,
        platform.width * gridSize,
        platform.height * gridSize,
      );

      if (isMirror) {
        // Mirror the platform horizontally
        rect = Rect.fromLTWH(
          size.width - rect.right,
          rect.top,
          rect.width,
          rect.height,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(8)),
        platformPaint,
      );
    }

    // Goal
    final goalPaint = Paint()
      ..color = (isMirror ? Color(0xFFFFD700) : Color(0xFF10B981))
          .withOpacity(isMirror ? mirrorOpacity : 1.0);

    var goalRect = Rect.fromLTWH(
      level.goal.x * gridSize,
      level.goal.y * gridSize,
      gridSize,
      gridSize,
    );

    if (isMirror) {
      goalRect = Rect.fromLTWH(
        size.width - goalRect.right,
        goalRect.top,
        goalRect.width,
        goalRect.height,
      );
    }

    canvas.drawOval(goalRect, goalPaint);

    // Player
    final playerPaint = Paint()
      ..color = (isMirror ? Color(0xFFFF8A65) : Color(0xFFF59E0B))
          .withOpacity(isMirror ? mirrorOpacity : 1.0);

    var playerPos = isMirror ? physics.mirrorPlayerPosition : physics.playerPosition;
    var playerRect = Rect.fromLTWH(
      playerPos.x * gridSize,
      playerPos.y * gridSize,
      gridSize,
      gridSize,
    );

    if (isMirror) {
      playerRect = Rect.fromLTWH(
        size.width - playerRect.right,
        playerRect.top,
        playerRect.width,
        playerRect.height,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(playerRect, Radius.circular(20)),
      playerPaint,
    );

    // Shimmer effect when mirror is active
    if (isMirror && mirrorOpacity > 0.5) {
      final shimmerPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..blendMode = BlendMode.plus;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        shimmerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}