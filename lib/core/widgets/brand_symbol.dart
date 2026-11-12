import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The ctrlSpend symbol: an amber coin with a navy ⌃ caret (DESIGN §2),
/// from the brand board's SVG. Decorative; pair it with the wordmark or a
/// label.
class BrandSymbol extends StatelessWidget {
  const new({this.size = 124, super.key});

  static const asset = 'assets/brand/symbol.svg';

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SvgPicture.asset(asset, width: size, height: size),
  );
}
