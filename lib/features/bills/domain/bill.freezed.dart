// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BillRepeat {

 RepeatUnit get unit; int get every; int? get day;
/// Create a copy of BillRepeat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillRepeatCopyWith<BillRepeat> get copyWith => _$BillRepeatCopyWithImpl<BillRepeat>(this as BillRepeat, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BillRepeat;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillRepeat&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.every, _this.every) || other.every == _this.every)&&(identical(other.day, _this.day) || other.day == _this.day));
}


@override
int get hashCode {
  final _this = this as BillRepeat;
  return Object.hash(runtimeType,_this.unit,_this.every,_this.day);
}

@override
String toString() {
  final _this = this as BillRepeat;
  return 'BillRepeat(unit: ${_this.unit}, every: ${_this.every}, day: ${_this.day})';
}


}

/// @nodoc
abstract mixin class $BillRepeatCopyWith<$Res>  {
  factory $BillRepeatCopyWith(BillRepeat value, $Res Function(BillRepeat) _then) = _$BillRepeatCopyWithImpl;
@useResult
$Res call({
 RepeatUnit unit, int every, int? day
});




}
/// @nodoc
class _$BillRepeatCopyWithImpl<$Res>
    implements $BillRepeatCopyWith<$Res> {
  _$BillRepeatCopyWithImpl(this._self, this._then);

  final BillRepeat _self;
  final $Res Function(BillRepeat) _then;

/// Create a copy of BillRepeat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unit = null,Object? every = null,Object? day = freezed,}) {
  return _then(BillRepeat(
unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as RepeatUnit,every: null == every ? _self.every : every // ignore: cast_nullable_to_non_nullable
as int,day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BillRepeat].
extension BillRepeatPatterns on BillRepeat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillRepeat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillRepeat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillRepeat value)  $default,){
final _that = this;
switch (_that) {
case _BillRepeat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillRepeat value)?  $default,){
final _that = this;
switch (_that) {
case _BillRepeat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RepeatUnit unit,  int every,  int? day)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillRepeat() when $default != null:
return $default(_that.unit,_that.every,_that.day);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RepeatUnit unit,  int every,  int? day)  $default,) {final _that = this;
switch (_that) {
case _BillRepeat():
return $default(_that.unit,_that.every,_that.day);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RepeatUnit unit,  int every,  int? day)?  $default,) {final _that = this;
switch (_that) {
case _BillRepeat() when $default != null:
return $default(_that.unit,_that.every,_that.day);case _:
  return null;

}
}

}

/// @nodoc


class _BillRepeat implements BillRepeat {
  const _BillRepeat({required this.unit, this.every = 1, this.day});
  

@override final  RepeatUnit unit;
@override@JsonKey() final  int every;
@override final  int? day;

/// Create a copy of BillRepeat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillRepeatCopyWith<_BillRepeat> get copyWith => __$BillRepeatCopyWithImpl<_BillRepeat>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillRepeat&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.every, every) || other.every == every)&&(identical(other.day, day) || other.day == day));
}


@override
int get hashCode {
    return Object.hash(runtimeType,unit,every,day);
}

@override
String toString() {
    return 'BillRepeat(unit: $unit, every: $every, day: $day)';
}


}

/// @nodoc
abstract mixin class _$BillRepeatCopyWith<$Res> implements $BillRepeatCopyWith<$Res> {
  factory _$BillRepeatCopyWith(_BillRepeat value, $Res Function(_BillRepeat) _then) = __$BillRepeatCopyWithImpl;
@override @useResult
$Res call({
 RepeatUnit unit, int every, int? day
});




}
/// @nodoc
class __$BillRepeatCopyWithImpl<$Res>
    implements _$BillRepeatCopyWith<$Res> {
  __$BillRepeatCopyWithImpl(this._self, this._then);

  final _BillRepeat _self;
  final $Res Function(_BillRepeat) _then;

/// Create a copy of BillRepeat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unit = null,Object? every = null,Object? day = freezed,}) {
  return _then(_BillRepeat(
unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as RepeatUnit,every: null == every ? _self.every : every // ignore: cast_nullable_to_non_nullable
as int,day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$Bill {

 int get id; String get name; int get amountMinor; int get categoryId; BillRepeat get repeat;/// A local calendar date, at midnight.
 DateTime get nextDue;/// Its tile on S27, picked on S28.
 CategoryIconKey get iconKey; CategoryColorKey get colorKey;/// Days before [nextDue] to remind; null means no reminder.
 int? get remindDaysBefore;
/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillCopyWith<Bill> get copyWith => _$BillCopyWithImpl<Bill>(this as Bill, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Bill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bill&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.amountMinor, _this.amountMinor) || other.amountMinor == _this.amountMinor)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.repeat, _this.repeat) || other.repeat == _this.repeat)&&(identical(other.nextDue, _this.nextDue) || other.nextDue == _this.nextDue)&&(identical(other.iconKey, _this.iconKey) || other.iconKey == _this.iconKey)&&(identical(other.colorKey, _this.colorKey) || other.colorKey == _this.colorKey)&&(identical(other.remindDaysBefore, _this.remindDaysBefore) || other.remindDaysBefore == _this.remindDaysBefore));
}


@override
int get hashCode {
  final _this = this as Bill;
  return Object.hash(runtimeType,_this.id,_this.name,_this.amountMinor,_this.categoryId,_this.repeat,_this.nextDue,_this.iconKey,_this.colorKey,_this.remindDaysBefore);
}

@override
String toString() {
  final _this = this as Bill;
  return 'Bill(id: ${_this.id}, name: ${_this.name}, amountMinor: ${_this.amountMinor}, categoryId: ${_this.categoryId}, repeat: ${_this.repeat}, nextDue: ${_this.nextDue}, iconKey: ${_this.iconKey}, colorKey: ${_this.colorKey}, remindDaysBefore: ${_this.remindDaysBefore})';
}


}

/// @nodoc
abstract mixin class $BillCopyWith<$Res>  {
  factory $BillCopyWith(Bill value, $Res Function(Bill) _then) = _$BillCopyWithImpl;
@useResult
$Res call({
 int id, String name, int amountMinor, int categoryId, BillRepeat repeat, DateTime nextDue, CategoryIconKey iconKey, CategoryColorKey colorKey, int? remindDaysBefore
});


$BillRepeatCopyWith<$Res> get repeat;

}
/// @nodoc
class _$BillCopyWithImpl<$Res>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._self, this._then);

  final Bill _self;
  final $Res Function(Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? amountMinor = null,Object? categoryId = null,Object? repeat = null,Object? nextDue = null,Object? iconKey = null,Object? colorKey = null,Object? remindDaysBefore = freezed,}) {
  return _then(Bill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as BillRepeat,nextDue: null == nextDue ? _self.nextDue : nextDue // ignore: cast_nullable_to_non_nullable
as DateTime,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as CategoryIconKey,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as CategoryColorKey,remindDaysBefore: freezed == remindDaysBefore ? _self.remindDaysBefore : remindDaysBefore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillRepeatCopyWith<$Res> get repeat {
  
  return $BillRepeatCopyWith<$Res>(_self.repeat, (value) {
    return _then(_self.copyWith(repeat: value));
  });
}
}


/// Adds pattern-matching-related methods to [Bill].
extension BillPatterns on Bill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bill value)  $default,){
final _that = this;
switch (_that) {
case _Bill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bill value)?  $default,){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int amountMinor,  int categoryId,  BillRepeat repeat,  DateTime nextDue,  CategoryIconKey iconKey,  CategoryColorKey colorKey,  int? remindDaysBefore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.name,_that.amountMinor,_that.categoryId,_that.repeat,_that.nextDue,_that.iconKey,_that.colorKey,_that.remindDaysBefore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int amountMinor,  int categoryId,  BillRepeat repeat,  DateTime nextDue,  CategoryIconKey iconKey,  CategoryColorKey colorKey,  int? remindDaysBefore)  $default,) {final _that = this;
switch (_that) {
case _Bill():
return $default(_that.id,_that.name,_that.amountMinor,_that.categoryId,_that.repeat,_that.nextDue,_that.iconKey,_that.colorKey,_that.remindDaysBefore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int amountMinor,  int categoryId,  BillRepeat repeat,  DateTime nextDue,  CategoryIconKey iconKey,  CategoryColorKey colorKey,  int? remindDaysBefore)?  $default,) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.name,_that.amountMinor,_that.categoryId,_that.repeat,_that.nextDue,_that.iconKey,_that.colorKey,_that.remindDaysBefore);case _:
  return null;

}
}

}

/// @nodoc


class _Bill implements Bill {
  const _Bill({required this.id, required this.name, required this.amountMinor, required this.categoryId, required this.repeat, required this.nextDue, required this.iconKey, required this.colorKey, this.remindDaysBefore});
  

@override final  int id;
@override final  String name;
@override final  int amountMinor;
@override final  int categoryId;
@override final  BillRepeat repeat;
/// A local calendar date, at midnight.
@override final  DateTime nextDue;
/// Its tile on S27, picked on S28.
@override final  CategoryIconKey iconKey;
@override final  CategoryColorKey colorKey;
/// Days before [nextDue] to remind; null means no reminder.
@override final  int? remindDaysBefore;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillCopyWith<_Bill> get copyWith => __$BillCopyWithImpl<_Bill>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.repeat, repeat) || other.repeat == repeat)&&(identical(other.nextDue, nextDue) || other.nextDue == nextDue)&&(identical(other.iconKey, iconKey) || other.iconKey == iconKey)&&(identical(other.colorKey, colorKey) || other.colorKey == colorKey)&&(identical(other.remindDaysBefore, remindDaysBefore) || other.remindDaysBefore == remindDaysBefore));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,amountMinor,categoryId,repeat,nextDue,iconKey,colorKey,remindDaysBefore);
}

@override
String toString() {
    return 'Bill(id: $id, name: $name, amountMinor: $amountMinor, categoryId: $categoryId, repeat: $repeat, nextDue: $nextDue, iconKey: $iconKey, colorKey: $colorKey, remindDaysBefore: $remindDaysBefore)';
}


}

/// @nodoc
abstract mixin class _$BillCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$BillCopyWith(_Bill value, $Res Function(_Bill) _then) = __$BillCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int amountMinor, int categoryId, BillRepeat repeat, DateTime nextDue, CategoryIconKey iconKey, CategoryColorKey colorKey, int? remindDaysBefore
});


@override $BillRepeatCopyWith<$Res> get repeat;

}
/// @nodoc
class __$BillCopyWithImpl<$Res>
    implements _$BillCopyWith<$Res> {
  __$BillCopyWithImpl(this._self, this._then);

  final _Bill _self;
  final $Res Function(_Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amountMinor = null,Object? categoryId = null,Object? repeat = null,Object? nextDue = null,Object? iconKey = null,Object? colorKey = null,Object? remindDaysBefore = freezed,}) {
  return _then(_Bill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,repeat: null == repeat ? _self.repeat : repeat // ignore: cast_nullable_to_non_nullable
as BillRepeat,nextDue: null == nextDue ? _self.nextDue : nextDue // ignore: cast_nullable_to_non_nullable
as DateTime,iconKey: null == iconKey ? _self.iconKey : iconKey // ignore: cast_nullable_to_non_nullable
as CategoryIconKey,colorKey: null == colorKey ? _self.colorKey : colorKey // ignore: cast_nullable_to_non_nullable
as CategoryColorKey,remindDaysBefore: freezed == remindDaysBefore ? _self.remindDaysBefore : remindDaysBefore // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillRepeatCopyWith<$Res> get repeat {
  
  return $BillRepeatCopyWith<$Res>(_self.repeat, (value) {
    return _then(_self.copyWith(repeat: value));
  });
}
}

// dart format on
