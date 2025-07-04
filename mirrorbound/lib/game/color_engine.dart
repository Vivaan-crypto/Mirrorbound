import 'dart:ui';

import 'package:mirrorbound/components/light_beam.dart';
import 'package:mirrorbound/components/light_switch.dart';
import 'package:mirrorbound/utils/constants.dart';

import '../components/mirror_portal.dart';

class ColorEngine {
  final List<LightBeam> activeBeams = [];
  final Map<LightSwitch, bool> switchStates = {};

  void activateMirror(MirrorPortal portal) {
    // Handle mirror activation logic
  }

  void addBeam(LightBeam beam) {
    activeBeams.add(beam);
    _updateColorMix();
  }

  void removeBeam(LightBeam beam) {
    activeBeams.remove(beam);
    _updateColorMix();
  }

  void _updateColorMix() {
    int r = 0, g = 0, b = 0;

    for (final beam in activeBeams) {
      r += beam.color.red;
      g += beam.color.green;
      b += beam.color.blue;
    }

    final count = activeBeams.length;
    final mixedColor = Color.fromRGBO(
      (r / count).round(),
      (g / count).round(),
      (b / count).round(),
      1.0,
    );

    // Update all switches with the mixed color
    for (final switchItem in switchStates.keys) {
      switchItem.checkActivation(mixedColor);
    }
  }
}