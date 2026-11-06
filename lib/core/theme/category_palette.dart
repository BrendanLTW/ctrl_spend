import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';

typedef CategoryTileColors = ({Color tile, Color icon});

/// Category tile background and icon colours, per theme.
/// Read them with `context.categoryColors.of(key)`.
@immutable
class CategoryColors extends ThemeExtension<CategoryColors> {
  const new(this.tiles);

  static const light = CategoryColors({
    CategoryColorKey.orange: (tile: Color(0xFFFFE2B8), icon: Color(0xFFC25E00)),
    CategoryColorKey.blue: (tile: Color(0xFFCDE6FB), icon: Color(0xFF1769C2)),
    CategoryColorKey.pink: (tile: Color(0xFFFBD3E1), icon: Color(0xFFC8174F)),
    CategoryColorKey.yellow: (tile: Color(0xFFFFF0B8), icon: Color(0xFF8A6100)),
    CategoryColorKey.purple: (tile: Color(0xFFE4DBF7), icon: Color(0xFF6D3FD1)),
    CategoryColorKey.green: (tile: Color(0xFFC9F3D5), icon: Color(0xFF1E8A43)),
    CategoryColorKey.red: (tile: Color(0xFFFEE4E2), icon: Color(0xFFD92D20)),
    CategoryColorKey.neutral: (
      tile: Color(0xFFEEF1F6),
      icon: Color(0xFF5B6B86),
    ),
  });

  static const dark = CategoryColors({
    CategoryColorKey.orange: (
      tile: Color.fromRGBO(251, 140, 0, 0.20),
      icon: Color(0xFFFFB547),
    ),
    CategoryColorKey.blue: (
      tile: Color.fromRGBO(33, 150, 243, 0.22),
      icon: Color(0xFF6CB8FF),
    ),
    CategoryColorKey.pink: (
      tile: Color.fromRGBO(240, 69, 122, 0.22),
      icon: Color(0xFFFF7AA2),
    ),
    CategoryColorKey.yellow: (
      tile: Color.fromRGBO(245, 184, 0, 0.20),
      icon: Color(0xFFFFD34D),
    ),
    CategoryColorKey.purple: (
      tile: Color.fromRGBO(124, 77, 219, 0.26),
      icon: Color(0xFFB69BFF),
    ),
    CategoryColorKey.green: (
      tile: Color.fromRGBO(23, 178, 106, 0.22),
      icon: Color(0xFF5BD996),
    ),
    CategoryColorKey.red: (
      tile: Color.fromRGBO(240, 68, 56, 0.22),
      icon: Color(0xFFFF8A80),
    ),
    CategoryColorKey.neutral: (
      tile: Color(0xFF232C3A),
      icon: Color(0xFF98A2B3),
    ),
  });

  final Map<CategoryColorKey, CategoryTileColors> tiles;

  CategoryTileColors of(CategoryColorKey key) => tiles[key]!;

  @override
  CategoryColors copyWith({Map<CategoryColorKey, CategoryTileColors>? tiles}) =>
      CategoryColors(tiles ?? this.tiles);

  @override
  CategoryColors lerp(CategoryColors? other, double t) {
    if (other == null) return this;
    return CategoryColors({
      for (final key in CategoryColorKey.values)
        key: (
          tile: Color.lerp(of(key).tile, other.of(key).tile, t)!,
          icon: Color.lerp(of(key).icon, other.of(key).icon, t)!,
        ),
    });
  }
}

extension CategoryColorsContext on BuildContext {
  CategoryColors get categoryColors =>
      Theme.of(this).extension<CategoryColors>()!;
}
