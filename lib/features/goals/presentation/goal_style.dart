import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/l10n/app_localizations.dart';

/// S31's six goal icons. Each sets the goal's type and colour (S29).
const List<CategoryIconKey> goalIcons = [
  CategoryIconKey.travel,
  CategoryIconKey.car,
  CategoryIconKey.home,
  CategoryIconKey.laptop,
  CategoryIconKey.heart,
  CategoryIconKey.gift,
];

/// A goal's colour, from its icon: Travel purple and Gadget pink as on
/// S29, the rest chosen to match (see docs/design-notes.md).
CategoryColorKey goalColour(CategoryIconKey icon) => switch (icon) {
  CategoryIconKey.travel => CategoryColorKey.purple,
  CategoryIconKey.car => CategoryColorKey.blue,
  CategoryIconKey.home => CategoryColorKey.green,
  CategoryIconKey.laptop => CategoryColorKey.pink,
  CategoryIconKey.heart => CategoryColorKey.red,
  _ => CategoryColorKey.orange,
};

extension GoalLabels on AppLocalizations {
  /// "Travel", "Gadget": the type S29's chip shows.
  String goalTypeOf(CategoryIconKey icon) => goalType(icon.name);
}
