import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/db/stored_dates.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:drift/drift.dart';

extension GoalRowMapper on GoalRow {
  Goal toEntity() => Goal(
    id: id,
    name: name,
    iconKey: CategoryIconKey.values.byName(iconKey),
    targetMinor: targetMinor,
    targetMonth: localDate(targetMonth),
    completedAt: completedAt,
    createdAt: createdAt,
  );
}

extension GoalMapper on Goal {
  /// The row to update.
  GoalsCompanion toCompanion() => GoalsCompanion(
    id: Value(id),
    name: Value(name),
    iconKey: Value(iconKey.name),
    targetMinor: Value(targetMinor),
    targetMonth: Value(storedDate(targetMonth)),
    completedAt: Value(completedAt?.toUtc()),
    createdAt: Value(createdAt.toUtc()),
  );
}

extension GoalContributionRowMapper on GoalContributionRow {
  GoalContribution toEntity() => GoalContribution(
    id: id,
    goalId: goalId,
    amountMinor: amountMinor,
    label: label,
    date: localDate(date),
  );
}
