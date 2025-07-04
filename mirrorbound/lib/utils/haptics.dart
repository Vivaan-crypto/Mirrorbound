import 'package:flutter/services.dart';

Future<void> triggerHapticFeedback() async {
  HapticFeedback.lightImpact();
}

Future<void> triggerErrorHaptic() async {
  HapticFeedback.heavyImpact();
}

Future<void> triggerCompletionHaptic() async {
  HapticFeedback.mediumImpact();
}