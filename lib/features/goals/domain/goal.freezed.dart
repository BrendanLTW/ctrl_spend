// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Goal {

 int get id; String get name; CategoryIconKey get iconKey; int get targetMinor;/// The first of the target month, local midnight.
 DateTime get targetMonth;/// When the goal was made, the start of its on-track plan (PRD §5.12).
 DateTime get createdAt;/// When saved first reached the target; null while it hasn't, or
/// after a withdrawal took it back below.
 DateTime? get completedAt;
/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalCopyWith<Goal> get copyWith => _$GoalCopyWithImpl<Goal>(this as Goal, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Goal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Goal&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.targetMinor, _this.targetMinor) || other.targetMinor == _this.targetMinor)&&(identical(other.targetMonth, _this.targetMonth) || other.targetMonth == _this.targetMonth)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt));
}


@override
int get hashCode {
  final _this = this as Goal;
  return Object.hash(runtimeType,_this.id,_this.name,_this.iconKey,_this.targetMinor,_this.targetMonth,_this.createdAt,_this.completedAt);
}

@override
String toString() {
  final _this = this as Goal;
  return 'Goal(id: ${_this.id}, name: ${_this.name}, iconKey: ${_this.iconKey}, targetMinor: ${_this.targetMinor}, targetMonth: ${_this.targetMonth}, createdAt: ${_this.createdAt}, completedAt: ${_this.completedAt})';
}


}

/// @nodoc
abstract mixin class $GoalCopyWith<$Res>  {
  factory $GoalCopyWith(Goal value, $Res Function(Goal) _then) = _$GoalCopyWithImpl;
@useResult
$Res call({
 int id, String name, CategoryIconKey iconKey, int targetMinor, DateTime targetMonth, DateTime createdAt, DateTime? completedAt
});




}
/// @nodoc
class _$GoalCopyWithImpl<$Res>
    implements $GoalCopyWith<$Res> {
  _$GoalCopyWithImpl(this._self, this._then);

  final Goal _self;
  final $Res Function(Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? iconKey = null,Object? targetMinor = null,Object? targetMonth = null,Object? createdAt = null,Object? completedAt = freezed,}) {
  return _then(Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as CategoryIconKey,targetMinor: null == targetMinor ? _self.targetMinor : targetMinor // ignore: cast_nullable_to_non_nullable
as int,targetMonth: null == targetMonth ? _self.targetMonth : targetMonth // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Goal].
extension GoalPatterns on Goal {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Goal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Goal value)  $default,){
final _that = this;
switch (_that) {
case _Goal():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Goal value)?  $default,){
final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  CategoryIconKey iconKey,  int targetMinor,  DateTime targetMonth,  DateTime createdAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.name,_that.iconKey,_that.targetMinor,_that.targetMonth,_that.createdAt,_that.completedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  CategoryIconKey iconKey,  int targetMinor,  DateTime targetMonth,  DateTime createdAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Goal():
return $default(_that.id,_that.name,_that.iconKey,_that.targetMinor,_that.targetMonth,_that.createdAt,_that.completedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  CategoryIconKey iconKey,  int targetMinor,  DateTime targetMonth,  DateTime createdAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Goal() when $default != null:
return $default(_that.id,_that.name,_that.iconKey,_that.targetMinor,_that.targetMonth,_that.createdAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Goal implements Goal {
  const _Goal({required this.id, required this.name, required this.iconKey, required this.targetMinor, required this.targetMonth, required this.createdAt, this.completedAt});
  

@override final  int id;
@override final  String name;
@override final  CategoryIconKey iconKey;
@override final  int targetMinor;
/// The first of the target month, local midnight.
@override final  DateTime targetMonth;
/// When the goal was made, the start of its on-track plan (PRD §5.12).
@override final  DateTime createdAt;
/// When saved first reached the target; null while it hasn't, or
/// after a withdrawal took it back below.
@override final  DateTime? completedAt;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalCopyWith<_Goal> get copyWith => __$GoalCopyWithImpl<_Goal>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Goal&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.targetMinor, targetMinor) || other.targetMinor == targetMinor)&&(identical(other.targetMonth, targetMonth) || other.targetMonth == targetMonth)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,iconKey,targetMinor,targetMonth,createdAt,completedAt);
}

@override
String toString() {
    return 'Goal(id: $id, name: $name, iconKey: $iconKey, targetMinor: $targetMinor, targetMonth: $targetMonth, createdAt: $createdAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$GoalCopyWith<$Res> implements $GoalCopyWith<$Res> {
  factory _$GoalCopyWith(_Goal value, $Res Function(_Goal) _then) = __$GoalCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, CategoryIconKey iconKey, int targetMinor, DateTime targetMonth, DateTime createdAt, DateTime? completedAt
});




}
/// @nodoc
class __$GoalCopyWithImpl<$Res>
    implements _$GoalCopyWith<$Res> {
  __$GoalCopyWithImpl(this._self, this._then);

  final _Goal _self;
  final $Res Function(_Goal) _then;

/// Create a copy of Goal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? iconKey = null,Object? targetMinor = null,Object? targetMonth = null,Object? createdAt = null,Object? completedAt = freezed,}) {
  return _then(_Goal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as CategoryIconKey,targetMinor: null == targetMinor ? _self.targetMinor : targetMinor // ignore: cast_nullable_to_non_nullable
as int,targetMonth: null == targetMonth ? _self.targetMonth : targetMonth // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$GoalContribution {

 int get id; int get goalId; int get amountMinor; String get label;/// A local calendar date, at midnight.
 DateTime get date;
/// Create a copy of GoalContribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalContributionCopyWith<GoalContribution> get copyWith => _$GoalContributionCopyWithImpl<GoalContribution>(this as GoalContribution, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GoalContribution;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalContribution&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.goalId, _this.goalId) || other.goalId == _this.goalId)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.date, _this.date) || other.date == _this.date));
}


@override
int get hashCode {
  final _this = this as GoalContribution;
  return Object.hash(runtimeType,_this.id,_this.goalId,_this.amountMinor,_this.label,_this.date);
}

@override
String toString() {
  final _this = this as GoalContribution;
  return 'GoalContribution(id: ${_this.id}, goalId: ${_this.goalId}, amountMinor: ${_this.amountMinor}, label: ${_this.label}, date: ${_this.date})';
}


}

/// @nodoc
abstract mixin class $GoalContributionCopyWith<$Res>  {
  factory $GoalContributionCopyWith(GoalContribution value, $Res Function(GoalContribution) _then) = _$GoalContributionCopyWithImpl;
@useResult
$Res call({
 int id, int goalId, int amountMinor, String label, DateTime date
});




}
/// @nodoc
class _$GoalContributionCopyWithImpl<$Res>
    implements $GoalContributionCopyWith<$Res> {
  _$GoalContributionCopyWithImpl(this._self, this._then);

  final GoalContribution _self;
  final $Res Function(GoalContribution) _then;

/// Create a copy of GoalContribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalId = null,Object? amountMinor = null,Object? label = null,Object? date = null,}) {
  return _then(GoalContribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as int,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalContribution].
extension GoalContributionPatterns on GoalContribution {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalContribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalContribution() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalContribution value)  $default,){
final _that = this;
switch (_that) {
case _GoalContribution():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalContribution value)?  $default,){
final _that = this;
switch (_that) {
case _GoalContribution() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int goalId,  int amountMinor,  String label,  DateTime date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalContribution() when $default != null:
return $default(_that.id,_that.goalId,_that.amountMinor,_that.label,_that.date);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int goalId,  int amountMinor,  String label,  DateTime date)  $default,) {final _that = this;
switch (_that) {
case _GoalContribution():
return $default(_that.id,_that.goalId,_that.amountMinor,_that.label,_that.date);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int goalId,  int amountMinor,  String label,  DateTime date)?  $default,) {final _that = this;
switch (_that) {
case _GoalContribution() when $default != null:
return $default(_that.id,_that.goalId,_that.amountMinor,_that.label,_that.date);case _:
  return null;

}
}

}

/// @nodoc


class _GoalContribution implements GoalContribution {
  const _GoalContribution({required this.id, required this.goalId, required this.amountMinor, required this.label, required this.date});
  

@override final  int id;
@override final  int goalId;
@override final  int amountMinor;
@override final  String label;
/// A local calendar date, at midnight.
@override final  DateTime date;

/// Create a copy of GoalContribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalContributionCopyWith<_GoalContribution> get copyWith => __$GoalContributionCopyWithImpl<_GoalContribution>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalContribution&&(identical(other.id, id) || other.id == id)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.label, label) || other.label == label)&&(identical(other.date, date) || other.date == date));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,goalId,amountMinor,label,date);
}

@override
String toString() {
    return 'GoalContribution(id: $id, goalId: $goalId, amountMinor: $amountMinor, label: $label, date: $date)';
}


}

/// @nodoc
abstract mixin class _$GoalContributionCopyWith<$Res> implements $GoalContributionCopyWith<$Res> {
  factory _$GoalContributionCopyWith(_GoalContribution value, $Res Function(_GoalContribution) _then) = __$GoalContributionCopyWithImpl;
@override @useResult
$Res call({
 int id, int goalId, int amountMinor, String label, DateTime date
});




}
/// @nodoc
class __$GoalContributionCopyWithImpl<$Res>
    implements _$GoalContributionCopyWith<$Res> {
  __$GoalContributionCopyWithImpl(this._self, this._then);

  final _GoalContribution _self;
  final $Res Function(_GoalContribution) _then;

/// Create a copy of GoalContribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalId = null,Object? amountMinor = null,Object? label = null,Object? date = null,}) {
  return _then(_GoalContribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,goalId: null == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as int,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
