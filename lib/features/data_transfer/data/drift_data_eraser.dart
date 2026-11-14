import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/features/data_transfer/domain/data_eraser.dart';

class DriftDataEraser implements DataEraser {
  new(this._db);

  final AppDatabase _db;

  @override
  Future<void> eraseAll() => _db.transaction(() async {
    // Children first: transactions refer to bills, and bills,
    // transactions and notifications to categories.
    await _db.delete(_db.transactions).go();
    await _db.delete(_db.bills).go();
    // Contributions go with their goals, limits with their snapshots.
    await _db.delete(_db.goals).go();
    await _db.delete(_db.periodSnapshots).go();
    await _db.delete(_db.notifications).go();
    await _db.delete(_db.categories).go();
    await _db.delete(_db.preferences).go();
    await _db.seedDefaultCategories();
  });
}
