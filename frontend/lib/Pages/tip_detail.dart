import 'package:flutter/material.dart';

class ReceipeDetailPage extends StatelessWidget {
  final int id;

  const ReceipeDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipe Detail"),
      ),
      body: Center(
        child: Text(
          'Receipe ID: $id',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
