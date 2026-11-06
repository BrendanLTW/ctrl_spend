import 'package:flutter/material.dart';

/// Shadows for floating elements (DESIGN §5). Cards are flat.
/// Read them with `context.shadows`.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const new({
    required this.bottomBar,
    required this.addButton,
    required this.toast,
    required this.dialog,
  });

  static const light = AppShadows(
    bottomBar: [
      BoxShadow(
        offset: Offset(0, 8),
        blurRadius: 28,
        color: Color.fromRGBO(16, 24, 40, 0.08),
      ),
    ],
    addButton: [
      BoxShadow(
        offset: Offset(0, 10),
        blurRadius: 24,
        color: Color.fromRGBO(16, 24, 40, 0.28),
      ),
    ],
    toast: [_toast],
    dialog: [_dialog],
  );

  static const dark = AppShadows(
    bottomBar: [
      BoxShadow(
        offset: Offset(0, 8),
        blurRadius: 28,
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
    ],
    addButton: [
      BoxShadow(
        offset: Offset(0, 10),
        blurRadius: 24,
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
    ],
    toast: [_toast],
    dialog: [_dialog],
  );

  static const _toast = BoxShadow(
    offset: Offset(0, 10),
    blurRadius: 24,
    color: Color.fromRGBO(16, 24, 40, 0.25),
  );
  static const _dialog = BoxShadow(
    offset: Offset(0, 24),
    blurRadius: 48,
    color: Color.fromRGBO(16, 24, 40, 0.24),
  );

  final List<BoxShadow> bottomBar;
  final List<BoxShadow> addButton;
  final List<BoxShadow> toast;
  final List<BoxShadow> dialog;

  @override
  AppShadows copyWith({
    List<BoxShadow>? bottomBar,
    List<BoxShadow>? addButton,
    List<BoxShadow>? toast,
    List<BoxShadow>? dialog,
  }) {
    return AppShadows(
      bottomBar: bottomBar ?? this.bottomBar,
      addButton: addButton ?? this.addButton,
      toast: toast ?? this.toast,
      dialog: dialog ?? this.dialog,
    );
  }

  @override
  AppShadows lerp(AppShadows? other, double t) {
    if (other == null) return this;
    return AppShadows(
      bottomBar: BoxShadow.lerpList(bottomBar, other.bottomBar, t)!,
      addButton: BoxShadow.lerpList(addButton, other.addButton, t)!,
      toast: BoxShadow.lerpList(toast, other.toast, t)!,
      dialog: BoxShadow.lerpList(dialog, other.dialog, t)!,
    );
  }
}

extension AppShadowsContext on BuildContext {
  AppShadows get shadows => Theme.of(this).extension<AppShadows>()!;
}
