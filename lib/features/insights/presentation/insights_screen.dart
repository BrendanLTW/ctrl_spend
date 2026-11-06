import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

// shortcut: placeholder screen; built in its own task.
class InsightsScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.l10n.tabInsights;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
