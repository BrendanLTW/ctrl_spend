import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds [AppIconView]s drawing [icon], as `find.byIcon` does for `Icon`.
Finder findAppIcon(AppIcon icon) => find.byWidgetPredicate(
  (w) => w is AppIconView && w.icon == icon,
  description: 'AppIconView($icon)',
);
