import 'package:flutter/material.dart';

// shortcut: placeholder screen with a hard-coded title; built in its own task.
class InsightsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: const Center(child: Text('Insights')),
    );
  }
}
