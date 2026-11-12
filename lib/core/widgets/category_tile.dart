import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';

/// The icon for a category icon key (DESIGN §8).
AppIcon categoryIcon(CategoryIconKey key) => switch (key) {
  CategoryIconKey.food => AppIcon.food,
  CategoryIconKey.coffee => AppIcon.coffee,
  CategoryIconKey.car => AppIcon.car,
  CategoryIconKey.bag => AppIcon.bag,
  CategoryIconKey.bolt => AppIcon.bolt,
  CategoryIconKey.film => AppIcon.film,
  CategoryIconKey.heart => AppIcon.heart,
  CategoryIconKey.gift => AppIcon.gift,
  CategoryIconKey.book => AppIcon.book,
  CategoryIconKey.travel => AppIcon.plane,
  CategoryIconKey.home => AppIcon.home,
  CategoryIconKey.phone => AppIcon.phone,
  CategoryIconKey.wallet => AppIcon.wallet,
};

enum CategoryTileSize {
  /// 56 × 56, radius 20: a screen's own subject, as S23's header.
  large(56, AppRadius.r20, 26),

  /// 48 × 48, radius 16: most screens.
  regular(48, AppRadius.r16, 22),

  /// 44 × 44, radius 15: Activity rows.
  compact(44, 15, 21),

  /// 28 × 28, radius 9: beside a value, as in S41's Category row.
  small(28, 9, 15);

  new(this.extent, this.radius, this.iconSize);

  final double extent;
  final double radius;
  final double iconSize;
}

/// A tinted icon tile (DESIGN §7): category tiles, and the coloured icons
/// on Settings rows. Decorative, so screen readers skip it.
class CategoryTile extends StatelessWidget {
  const new({
    required this.icon,
    required this.color,
    this.size = CategoryTileSize.regular,
    super.key,
  });

  /// A tile for a category's stored icon key.
  new forKey(
    CategoryIconKey iconKey, {
    required this.color,
    this.size = CategoryTileSize.regular,
    super.key,
  }) : icon = categoryIcon(iconKey);

  final AppIcon icon;
  final CategoryColorKey color;
  final CategoryTileSize size;

  @override
  Widget build(BuildContext context) {
    final colors = context.categoryColors.of(color);
    return ExcludeSemantics(
      child: Container(
        width: size.extent,
        height: size.extent,
        decoration: BoxDecoration(
          color: colors.tile,
          borderRadius: BorderRadius.circular(size.radius),
        ),
        child: AppIconView(
          icon,
          size: size.iconSize,
          color: colors.icon,
          stroke: AppIconStroke.tile,
        ),
      ),
    );
  }
}
