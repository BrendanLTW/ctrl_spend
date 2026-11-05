import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// shortcut: placeholder screen with a hard-coded title; built in its own task.
class DashboardScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: const Center(child: Text('Home')),
    );
  }
}
