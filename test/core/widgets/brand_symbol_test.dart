import 'dart:io';

import 'package:ctrlspend/core/widgets/brand_symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

void main() {
  test('the mark asset is bundled', () {
    expect(File(BrandSymbol.asset).existsSync(), isTrue);
    expect(
      File('pubspec.yaml').readAsStringSync(),
      contains('- ${BrandSymbol.asset}'),
    );
  });

  group('brandSvgForFlutter', () {
    final mark = File(BrandSymbol.asset).readAsStringSync();

    test('takes out the −90° turn, so the arc starts at 12', () {
      expect(mark, contains('rotate(-90 60 55.5)'));
      expect(brandSvgForFlutter(mark), isNot(contains('rotate(-90')));
    });

    test("scales the dashes by the ring's scale", () {
      // The mark's ring is at scale(.92): 54.3 × .92, 150.8 × .92.
      expect(
        brandSvgForFlutter(mark),
        contains('stroke-dasharray="${54.3 * .92} ${150.8 * .92}"'),
      );
    });

    test('leaves an unscaled ring as it is', () {
      const ring =
          '<circle stroke-dasharray="54.3 150.8" '
          'transform="rotate(-90 60 55.5)"/>';
      expect(
        brandSvgForFlutter(ring),
        '<circle stroke-dasharray="54.3 150.8"/>',
      );
    });
  });

  testWidgets('BrandSymbol is a decorative SVG at the given size', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      themes.first.theme,
      const Center(child: BrandSymbol(size: 76)),
    );
    expect(tester.getSize(find.byType(SvgPicture)), const Size(76, 76));
    expect(
      tester.getSemantics(find.byType(BrandSymbol)).label,
      isEmpty,
      reason: 'pair it with the wordmark or a label',
    );
    handle.dispose();
  });
}
