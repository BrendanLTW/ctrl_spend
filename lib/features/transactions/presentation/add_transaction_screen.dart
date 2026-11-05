import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// shortcut: placeholder screen with a hard-coded title; built in its own task.
class AddTransactionScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add transaction'),
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(child: Text('Add transaction')),
    );
  }
}
