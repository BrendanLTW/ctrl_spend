import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// shortcut: placeholder screen; built in its own task.
class DashboardScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabHome),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: Center(child: Text(l10n.tabHome)),
    );
  }
}
