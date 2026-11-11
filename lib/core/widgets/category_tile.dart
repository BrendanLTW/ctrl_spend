import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';

/// The icon for a category icon key (DESIGN §8).
// shortcut: Material rounded icons stand in for the designs' 1.9-stroke line
// icons until the icon set lands in the fidelity pass (task 4.2).
IconData categoryIcon(CategoryIconKey key) => switch (key) {
  CategoryIconKey.food => Icons.restaurant_rounded,
  CategoryIconKey.coffee => Icons.coffee_outlined,
  CategoryIconKey.car => Icons.directions_car_outlined,
  CategoryIconKey.bag => Icons.shopping_bag_outlined,
  CategoryIconKey.bolt => Icons.bolt_rounded,
  CategoryIconKey.film => Icons.movie_outlined,
  CategoryIconKey.heart => Icons.favorite_border_rounded,
  CategoryIconKey.gift => Icons.card_giftcard_rounded,
  CategoryIconKey.book => Icons.menu_book_outlined,
  CategoryIconKey.travel => Icons.near_me_outlined,
  CategoryIconKey.home => Icons.home_outlined,
  CategoryIconKey.phone => Icons.smartphone_rounded,
  CategoryIconKey.wallet => Icons.account_balance_wallet_outlined,
};

enum CategoryTileSize {
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

  final IconData icon;
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
        child: Icon(icon, size: size.iconSize, color: colors.icon),
      ),
    );
  }
}
