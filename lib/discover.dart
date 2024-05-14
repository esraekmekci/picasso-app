import 'package:flutter/material.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: Center(
        child: Text('Discover Page Content'),
      ),
    );
  }
}
