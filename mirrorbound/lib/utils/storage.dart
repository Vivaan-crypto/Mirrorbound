import 'package:shared_preferences/shared_preferences.dart';

Future<void> initStorage() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('unlocked_levels')) {
    await prefs.setInt('unlocked_levels', 10);
  }
  if (!prefs.containsKey('owned_skins')) {
    await prefs.setStringList('owned_skins', ['default']);
  }
}

Future<void> unlockLevels(int level) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('unlocked_levels', level);
}

Future<int> getUnlockedLevels() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('unlocked_levels') ?? 10;
}

Future<List<String>> getOwnedSkins() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('owned_skins') ?? ['default'];
}

Future<void> purchaseSkin(String skinId) async {
  final prefs = await SharedPreferences.getInstance();
  final owned = await getOwnedSkins();
  if (!owned.contains(skinId)) {
    owned.add(skinId);
    await prefs.setStringList('owned_skins', owned);
  }
}