import 'dart:io';

import 'package:ctrl_spend/core/theme/app_theme.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every icon is bundled, with the stroke the loader rewrites', () {
    for (final icon in AppIcon.values) {
      final file = File(icon.asset);
      expect(file.existsSync(), isTrue, reason: icon.asset);
      expect(
        file.readAsStringSync(),
        contains('stroke-width="2"'),
        reason: icon.asset,
      );
    }
    expect(File('assets/icons/LICENSE').existsSync(), isTrue);
  });

  testWidgets('takes size and colour from the IconTheme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const IconTheme(
          data: IconThemeData(size: 30, color: Color(0xFF123456)),
          child: Center(child: AppIconView(AppIcon.home)),
        ),
      ),
    );
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 30);
    expect(
      svg.colorFilter,
      const ColorFilter.mode(Color(0xFF123456), BlendMode.srcIn),
    );
    expect(tester.getSize(find.byType(AppIconView)), const Size(30, 30));
  });
}
