import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';

/// The 8 categories seeded on first launch (PRD §8), in display order.
/// Colours follow the Category manager design. Stored as data, so they're
/// in English and the user can rename them.
const defaultCategories =
    <
      ({
        String name,
        TransactionType type,
        CategoryIconKey icon,
        CategoryColorKey colour,
      })
    >[
      (
        name: 'Food',
        type: TransactionType.expense,
        icon: CategoryIconKey.food,
        colour: CategoryColorKey.orange,
      ),
      (
        name: 'Transport',
        type: TransactionType.expense,
        icon: CategoryIconKey.car,
        colour: CategoryColorKey.blue,
      ),
      (
        name: 'Shopping',
        type: TransactionType.expense,
        icon: CategoryIconKey.bag,
        colour: CategoryColorKey.pink,
      ),
      (
        name: 'Bills',
        type: TransactionType.expense,
        icon: CategoryIconKey.bolt,
        colour: CategoryColorKey.yellow,
      ),
      (
        name: 'Fun',
        type: TransactionType.expense,
        icon: CategoryIconKey.film,
        colour: CategoryColorKey.purple,
      ),
      (
        name: 'Health',
        type: TransactionType.expense,
        icon: CategoryIconKey.heart,
        colour: CategoryColorKey.red,
      ),
      (
        name: 'Salary',
        type: TransactionType.income,
        icon: CategoryIconKey.wallet,
        colour: CategoryColorKey.green,
      ),
      (
        name: 'Gifts',
        type: TransactionType.income,
        icon: CategoryIconKey.gift,
        colour: CategoryColorKey.neutral,
      ),
    ];
