import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: const Center(
        child: Text('Favorites Page Content'),
      ),
    );
  }
}
