import 'package:haptic_feedback/haptic_feedback.dart';

Future<void> triggerHapticFeedback() async {
  await Haptics.vibrate(HapticsType.success);
}

Future<void> triggerErrorHaptic() async {
  await Haptics.vibrate(HapticsType.error);
}

Future<void> triggerCompletionHaptic() async {
  await Haptics.vibrate(HapticsType.heavy);
}