// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'period.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MonthStartDay {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthStartDay);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MonthStartDay()';
}


}

/// @nodoc
class $MonthStartDayCopyWith<$Res>  {
$MonthStartDayCopyWith(MonthStartDay _, $Res Function(MonthStartDay) __);
}


/// Adds pattern-matching-related methods to [MonthStartDay].
extension MonthStartDayPatterns on MonthStartDay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DayOfMonth value)?  day,TResult Function( LastDayOfMonth value)?  last,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DayOfMonth() when day != null:
return day(_that);case LastDayOfMonth() when last != null:
return last(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DayOfMonth value)  day,required TResult Function( LastDayOfMonth value)  last,}){
final _that = this;
switch (_that) {
case DayOfMonth():
return day(_that);case LastDayOfMonth():
return last(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DayOfMonth value)?  day,TResult? Function( LastDayOfMonth value)?  last,}){
final _that = this;
switch (_that) {
case DayOfMonth() when day != null:
return day(_that);case LastDayOfMonth() when last != null:
return last(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int day)?  day,TResult Function()?  last,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DayOfMonth() when day != null:
return day(_that.day);case LastDayOfMonth() when last != null:
return last();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int day)  day,required TResult Function()  last,}) {final _that = this;
switch (_that) {
case DayOfMonth():
return day(_that.day);case LastDayOfMonth():
return last();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int day)?  day,TResult? Function()?  last,}) {final _that = this;
switch (_that) {
case DayOfMonth() when day != null:
return day(_that.day);case LastDayOfMonth() when last != null:
return last();case _:
  return null;

}
}

}

/// @nodoc


class DayOfMonth implements MonthStartDay {
  const DayOfMonth(this.day): assert(day >= 1 && day <= 28, 'day 1–28');
  

 final  int day;

/// Create a copy of MonthStartDay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DayOfMonthCopyWith<DayOfMonth> get copyWith => _$DayOfMonthCopyWithImpl<DayOfMonth>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DayOfMonth&&(identical(other.day, day) || other.day == day));
}


@override
int get hashCode {
    return Object.hash(runtimeType,day);
}

@override
String toString() {
    return 'MonthStartDay.day(day: $day)';
}


}

/// @nodoc
abstract mixin class $DayOfMonthCopyWith<$Res> implements $MonthStartDayCopyWith<$Res> {
  factory $DayOfMonthCopyWith(DayOfMonth value, $Res Function(DayOfMonth) _then) = _$DayOfMonthCopyWithImpl;
@useResult
$Res call({
 int day
});




}
/// @nodoc
class _$DayOfMonthCopyWithImpl<$Res>
    implements $DayOfMonthCopyWith<$Res> {
  _$DayOfMonthCopyWithImpl(this._self, this._then);

  final DayOfMonth _self;
  final $Res Function(DayOfMonth) _then;

/// Create a copy of MonthStartDay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? day = null,}) {
  return _then(DayOfMonth(
null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class LastDayOfMonth implements MonthStartDay {
  const LastDayOfMonth();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LastDayOfMonth);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MonthStartDay.last()';
}


}




// dart format on
