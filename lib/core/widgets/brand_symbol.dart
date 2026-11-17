import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The ctrlSpend mark: a green budget ring on a charcoal keycap (DESIGN §2),
/// from `assets/brand/ctrlspend_mark.svg`. Decorative; pair it with the
/// wordmark or a label.
class BrandSymbol extends StatelessWidget {
  const new({this.size = 116, super.key});

  static const asset = 'assets/brand/ctrlspend_mark.svg';

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture(const _MarkLoader(asset), width: size, height: size),
  );
}

/// The brand SVGs as flutter_svg should draw them; the files stay exactly
/// as the brand board exports them. Two differences from SVG:
/// - SVG starts a circle at 3 o'clock, so the files turn the ring's arc by
///   −90° to start it at 12. flutter_svg already starts at 12, so the turn
///   is taken out.
/// - SVG measures dashes before the ring's `scale(…)`, flutter_svg after,
///   so the dash lengths are scaled to keep the arc at 36% of the ring.
String brandSvgForFlutter(String svg) {
  final scale = double.parse(
    RegExp(r'scale\(([\d.]+)\)').firstMatch(svg)?.group(1) ?? '1',
  );
  String scaled(String dashes) =>
      [for (final n in dashes.split(' ')) double.parse(n) * scale].join(' ');
  return svg
      .replaceAll(' transform="rotate(-90 60 55.5)"', '')
      .replaceAllMapped(
        RegExp(r'stroke-dasharray="([\d. ]+)"'),
        (m) => 'stroke-dasharray="${scaled(m[1]!)}"',
      );
}

class _MarkLoader extends SvgAssetLoader {
  const new(super.assetName);

  @override
  String provideSvg(ByteData? message) => brandSvgForFlutter(
    utf8.decode(Uint8List.sublistView(message!), allowMalformed: true),
  );
}
