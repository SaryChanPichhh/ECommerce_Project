import 'package:flutter/material.dart';

/// Search page placeholder.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Search', style: TextStyle(fontSize: 20, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
