import 'package:flutter/material.dart';
import 'package:mirrorbound/utils/storage.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<String> ownedSkins = [];
  final cosmetics = [
    {'id': 'cloak_red', 'name': 'Red Cloak', 'price': 0.49},
    {'id': 'cloak_blue', 'name': 'Blue Cloak', 'price': 0.49},
    {'id': 'trail_sparkle', 'name': 'Sparkle Trail', 'price': 0.99},
    {'id': 'trail_glow', 'name': 'Glow Trail', 'price': 0.99},
  ];

  @override
  void initState() {
    super.initState();
    _loadOwnedSkins();
  }

  Future<void> _loadOwnedSkins() async {
    final skins = await getOwnedSkins();
    setState(() => ownedSkins = skins);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cosmetic Shop')),
      body: ListView.builder(
        itemCount: cosmetics.length,
        itemBuilder: (context, index) {
          final item = cosmetics[index];
          final isOwned = ownedSkins.contains(item['id'] as String); // Added cast

          return ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(item['name']),
            subtitle: Text(isOwned ? 'Owned' : '\$${item['price']}'),
            trailing: isOwned
                ? const Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
              onPressed: () => _purchaseItem(item['id'] as String), // Added cast
              child: const Text('Buy'),
            ),
          );
        },
      ),
    );
  }

  void _purchaseItem(String id) async { // Added type
    await purchaseSkin(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase successful!')),
    );
    _loadOwnedSkins();
  }
}