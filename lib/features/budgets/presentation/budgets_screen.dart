import 'package:flutter/material.dart';

// shortcut: placeholder screen with a hard-coded title; built in its own task.
class BudgetsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: const Center(child: Text('Budgets')),
    );
  }
}
