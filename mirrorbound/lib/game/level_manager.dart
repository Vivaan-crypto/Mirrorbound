import 'dart:convert';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:mirrorbound/components/mirror_portal.dart';
import 'package:mirrorbound/components/platform.dart';
import 'package:mirrorbound/components/hazard.dart';
import 'package:mirrorbound/game/color_engine.dart';

class Level {
  final Vector2 playerStart;
  final List<Platform> platforms;
  final List<MirrorPortal> mirrors;
  final List<Hazard> hazards;
  final Vector2 goal;

  Level({
    required this.playerStart,
    required this.platforms,
    required this.mirrors,
    required this.hazards,
    required this.goal,
  });
}

class LevelManager {
  static Future<Level> loadLevel(int levelId) async {
    final data = await rootBundle.loadString('assets/levels/level_$levelId.json');
    final json = jsonDecode(data);

    return Level(
      playerStart: Vector2(json['playerStart'][0].toDouble(),
          json['playerStart'][1].toDouble()),
      platforms: (json['platforms'] as List).map((p) => Platform(
        position: Vector2(p['x'].toDouble(), p['y'].toDouble()),
        size: Vector2(p['width'].toDouble(), p['height'].toDouble()),
      )).toList(),
      mirrors: (json['mirrors'] as List).map((m) => MirrorPortal(
        colorEngine: ColorEngine(),
        isRealWorld: m['isRealWorld'],
        position: Vector2(m['x'].toDouble(), m['y'].toDouble()), // Added position
      )).toList(),
      hazards: (json['hazards'] as List).map((h) => Hazard(
        position: Vector2(h['x'].toDouble(), h['y'].toDouble()),
        size: Vector2(h['width'].toDouble(), h['height'].toDouble()),
      )).toList(),
      goal: Vector2(json['goal'][0].toDouble(), json['goal'][1].toDouble()),
    );
  }
}