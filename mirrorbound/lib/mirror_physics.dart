import 'dart:math' as math;
import 'level_manager.dart';

enum Direction { up, down, left, right }

class Position {
  double x, y;
  Position(this.x, this.y);

  Position copy() => Position(x, y);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Position && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class MirrorPhysics {
  late GameLevel _currentLevel;
  late Position _playerPosition;
  late Position _mirrorPlayerPosition;
  bool _gravityInverted = false;
  bool _mirrorGravityInverted = false;

  List<Position> _moveHistory = [];

  Position get playerPosition => _playerPosition;
  Position get mirrorPlayerPosition => _mirrorPlayerPosition;
  GameLevel get currentLevel => _currentLevel;
  bool get gravityInverted => _gravityInverted;
  bool get mirrorGravityInverted => _mirrorGravityInverted;

  void loadLevel(GameLevel level) {
    _currentLevel = level;
    _playerPosition = level.startPosition.copy();
    _mirrorPlayerPosition = _mirrorPosition(level.startPosition);
    _gravityInverted = false;
    _mirrorGravityInverted = false;
    _moveHistory.clear();
  }

  Position _mirrorPosition(Position pos) {
    // Mirror horizontally within the level bounds
    return Position(
      _currentLevel.width - 1 - pos.x,
      pos.y,
    );
  }

  bool movePlayer(Direction direction) {
    // Store current state for undo
    _moveHistory.add(_playerPosition.copy());

    Position newPos = _playerPosition.copy();
    Position newMirrorPos = _mirrorPlayerPosition.copy();

    // Calculate movement
    switch (direction) {
      case Direction.up:
        newPos.y -= 1;
        newMirrorPos.y -= _mirrorGravityInverted ? -1 : 1;
        break;
      case Direction.down:
        newPos.y += 1;
        newMirrorPos.y += _mirrorGravityInverted ? -1 : 1;
        break;
      case Direction.left:
        newPos.x -= 1;
        newMirrorPos.x += 1; // Mirror movement
        break;
      case Direction.right:
        newPos.x += 1;
        newMirrorPos.x -= 1; // Mirror movement
        break;
    }

    // Check bounds
    if (!_isValidPosition(newPos) || !_isValidPosition(newMirrorPos)) {
      return false;
    }

    // Check collisions
    if (_isCollidingWithPlatform(newPos) || _isCollidingWithPlatform(newMirrorPos)) {
      return false;
    }

    // Apply gravity
    newPos = _applyGravity(newPos, _gravityInverted);
    newMirrorPos = _applyGravity(newMirrorPos, _mirrorGravityInverted);

    // Update positions
    _playerPosition = newPos;
    _mirrorPlayerPosition = newMirrorPos;

    return true;
  }

  Position _applyGravity(Position pos, bool inverted) {
    Position newPos = pos.copy();

    // Apply gravity until we hit a platform or boundary
    while (true) {
      Position nextPos = newPos.copy();

      if (inverted) {
        nextPos.y -= 1; // Gravity up
      } else {
        nextPos.y += 1; // Gravity down
      }

      // Check if we hit a boundary
      if (!_isValidPosition(nextPos)) {
        break;
      }

      // Check if we hit a platform
      if (_isCollidingWithPlatform(nextPos)) {
        break;
      }

      newPos = nextPos;
    }

    return newPos;
  }

  bool _isValidPosition(Position pos) {
    return pos.x >= 0 &&
        pos.x < _currentLevel.width &&
        pos.y >= 0 &&
        pos.y < _currentLevel.height;
  }

  bool _isCollidingWithPlatform(Position pos) {
    for (var platform in _currentLevel.platforms) {
      if (pos.x >= platform.x &&
          pos.x < platform.x + platform.width &&
          pos.y >= platform.y &&
          pos.y < platform.y + platform.height) {
        return true;
      }
    }
    return false;
  }

  void invertGravity() {
    _gravityInverted = !_gravityInverted;
  }

  void invertMirrorGravity() {
    _mirrorGravityInverted = !_mirrorGravityInverted;
  }

  bool isLevelComplete() {
    return (_playerPosition == _currentLevel.goal) ||
        (_mirrorPlayerPosition == _currentLevel.goal);
  }

  void undoMove() {
    if (_moveHistory.isNotEmpty) {
      _playerPosition = _moveHistory.removeLast();
      _mirrorPlayerPosition = _mirrorPosition(_playerPosition);
    }
  }

  // Light-weaving mechanics for advanced levels
  Map<String, LightBeam> _lightBeams = {};

  void addLightBeam(String id, Position start, Position end, Color color) {
    _lightBeams[id] = LightBeam(start, end, color);
  }

  void removeLightBeam(String id) {
    _lightBeams.remove(id);
  }

  List<LightBeam> get activeLightBeams => _lightBeams.values.toList();

  bool isLightBridgeActive(Position pos) {
    for (var beam in _lightBeams.values) {
      if (beam.containsPosition(pos)) {
        return true;
      }
    }
    return false;
  }

  // Mirror portal mechanics
  List<MirrorPortal> _portals = [];

  void addPortal(MirrorPortal portal) {
    _portals.add(portal);
  }

  void clearPortals() {
    _portals.clear();
  }

  bool canTeleportThroughPortal(Position pos) {
    for (var portal in _portals) {
      if (portal.position == pos && portal.isActive) {
        return true;
      }
    }
    return false;
  }

  Position? getPortalDestination(Position pos) {
    for (var portal in _portals) {
      if (portal.position == pos && portal.isActive) {
        return portal.destination;
      }
    }
    return null;
  }
}

enum Color { red, green, blue, yellow, magenta, cyan, white }

class LightBeam {
  final Position start;
  final Position end;
  final Color color;

  LightBeam(this.start, this.end, this.color);

  bool containsPosition(Position pos) {
    // Simple line collision detection
    double distance = _pointToLineDistance(pos, start, end);
    return distance < 0.5; // Within half a grid unit
  }

  double _pointToLineDistance(Position point, Position lineStart, Position lineEnd) {
    double A = point.x - lineStart.x;
    double B = point.y - lineStart.y;
    double C = lineEnd.x - lineStart.x;
    double D = lineEnd.y - lineStart.y;

    double dot = A * C + B * D;
    double lenSq = C * C + D * D;

    if (lenSq == 0) return math.sqrt(A * A + B * B);

    double param = dot / lenSq;

    double xx, yy;

    if (param < 0) {
      xx = lineStart.x;
      yy = lineStart.y;
    } else if (param > 1) {
      xx = lineEnd.x;
      yy = lineEnd.y;
    } else {
      xx = lineStart.x + param * C;
      yy = lineStart.y + param * D;
    }

    double dx = point.x - xx;
    double dy = point.y - yy;
    return math.sqrt(dx * dx + dy * dy);
  }
}

class MirrorPortal {
  final Position position;
  final Position destination;
  final bool isActive;
  final double activationRadius;

  MirrorPortal(this.position, this.destination, {this.isActive = true, this.activationRadius = 1.0});
}

// Advanced physics calculations for complex mirror interactions
class MirrorPhysicsAdvanced {
  static List<Position> calculateReflectionPath(Position start, Position end, List<Platform> mirrors) {
    List<Position> path = [start];
    Position current = start;
    Position direction = Position(end.x - start.x, end.y - start.y);

    // Normalize direction
    double length = math.sqrt(direction.x * direction.x + direction.y * direction.y);
    direction.x /= length;
    direction.y /= length;

    int maxBounces = 10;
    int bounces = 0;

    while (bounces < maxBounces) {
      // Find next collision point
      Position? collision = _findNextCollision(current, direction, mirrors);

      if (collision == null) {
        path.add(Position(current.x + direction.x * 100, current.y + direction.y * 100));
        break;
      }

      path.add(collision);

      // Calculate reflection
      Position normal = _calculateSurfaceNormal(collision, mirrors);
      direction = _reflect(direction, normal);
      current = collision;
      bounces++;
    }

    return path;
  }

  static Position? _findNextCollision(Position start, Position direction, List<Platform> mirrors) {
    double minDistance = double.infinity;
    Position? closestCollision;

    for (var mirror in mirrors) {
      Position? collision = _rayPlatformIntersection(start, direction, mirror);
      if (collision != null) {
        double distance = math.sqrt(
            (collision.x - start.x) * (collision.x - start.x) +
                (collision.y - start.y) * (collision.y - start.y)
        );

        if (distance < minDistance) {
          minDistance = distance;
          closestCollision = collision;
        }
      }
    }

    return closestCollision;
  }

  static Position? _rayPlatformIntersection(Position start, Position direction, Platform platform) {
    // Simplified ray-rectangle intersection
    double t1 = (platform.x - start.x) / direction.x;
    double t2 = (platform.x + platform.width - start.x) / direction.x;
    double t3 = (platform.y - start.y) / direction.y;
    double t4 = (platform.y + platform.height - start.y) / direction.y;

    double tMin = math.max(math.min(t1, t2), math.min(t3, t4));
    double tMax = math.min(math.max(t1, t2), math.max(t3, t4));

    if (tMax < 0 || tMin > tMax) return null;

    double t = tMin > 0 ? tMin : tMax;
    return Position(start.x + direction.x * t, start.y + direction.y * t);
  }

  static Position _calculateSurfaceNormal(Position collision, List<Platform> mirrors) {
    // Simplified normal calculation - assumes axis-aligned rectangles
    return Position(0, -1); // Default upward normal
  }

  static Position _reflect(Position incident, Position normal) {
    // Reflection formula: r = d - 2(d·n)n
    double dot = incident.x * normal.x + incident.y * normal.y;
    return Position(
      incident.x - 2 * dot * normal.x,
      incident.y - 2 * dot * normal.y,
    );
  }
}