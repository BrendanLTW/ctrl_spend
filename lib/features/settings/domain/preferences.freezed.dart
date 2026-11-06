// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Preferences {

 String get userName; String get currencyCode; MonthStartDay get monthStartDay;/// Null means no overall budget.
 int? get monthlyBudgetMinor; AppTheme get theme; bool get dailyReminderOn;/// Minutes after local midnight; 21:00 by default (S07).
 int get dailyReminderMinutes; bool get budgetAlertsOn; bool get weeklySummaryOn; bool get onboardingComplete;
/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreferencesCopyWith<Preferences> get copyWith => _$PreferencesCopyWithImpl<Preferences>(this as Preferences, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Preferences;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preferences&&(identical(other.userName, _this.userName) || other.userName == _this.userName)&&(identical(other.currencyCode, _this.currencyCode) || other.currencyCode == _this.currencyCode)&&(identical(other.monthStartDay, _this.monthStartDay) || other.monthStartDay == _this.monthStartDay)&&(identical(other.monthlyBudgetMinor, _this.monthlyBudgetMinor) || other.monthlyBudgetMinor == _this.monthlyBudgetMinor)&&(identical(other.theme, _this.theme) || other.theme == _this.theme)&&(identical(other.dailyReminderOn, _this.dailyReminderOn) || other.dailyReminderOn == _this.dailyReminderOn)&&(identical(other.dailyReminderMinutes, _this.dailyReminderMinutes) || other.dailyReminderMinutes == _this.dailyReminderMinutes)&&(identical(other.budgetAlertsOn, _this.budgetAlertsOn) || other.budgetAlertsOn == _this.budgetAlertsOn)&&(identical(other.weeklySummaryOn, _this.weeklySummaryOn) || other.weeklySummaryOn == _this.weeklySummaryOn)&&(identical(other.onboardingComplete, _this.onboardingComplete) || other.onboardingComplete == _this.onboardingComplete));
}


@override
int get hashCode {
  final _this = this as Preferences;
  return Object.hash(runtimeType,_this.userName,_this.currencyCode,_this.monthStartDay,_this.monthlyBudgetMinor,_this.theme,_this.dailyReminderOn,_this.dailyReminderMinutes,_this.budgetAlertsOn,_this.weeklySummaryOn,_this.onboardingComplete);
}

@override
String toString() {
  final _this = this as Preferences;
  return 'Preferences(userName: ${_this.userName}, currencyCode: ${_this.currencyCode}, monthStartDay: ${_this.monthStartDay}, monthlyBudgetMinor: ${_this.monthlyBudgetMinor}, theme: ${_this.theme}, dailyReminderOn: ${_this.dailyReminderOn}, dailyReminderMinutes: ${_this.dailyReminderMinutes}, budgetAlertsOn: ${_this.budgetAlertsOn}, weeklySummaryOn: ${_this.weeklySummaryOn}, onboardingComplete: ${_this.onboardingComplete})';
}


}

/// @nodoc
abstract mixin class $PreferencesCopyWith<$Res>  {
  factory $PreferencesCopyWith(Preferences value, $Res Function(Preferences) _then) = _$PreferencesCopyWithImpl;
@useResult
$Res call({
 String userName, String currencyCode, MonthStartDay monthStartDay, int? monthlyBudgetMinor, AppTheme theme, bool dailyReminderOn, int dailyReminderMinutes, bool budgetAlertsOn, bool weeklySummaryOn, bool onboardingComplete
});


$MonthStartDayCopyWith<$Res> get monthStartDay;

}
/// @nodoc
class _$PreferencesCopyWithImpl<$Res>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._self, this._then);

  final Preferences _self;
  final $Res Function(Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userName = null,Object? currencyCode = null,Object? monthStartDay = null,Object? monthlyBudgetMinor = freezed,Object? theme = null,Object? dailyReminderOn = null,Object? dailyReminderMinutes = null,Object? budgetAlertsOn = null,Object? weeklySummaryOn = null,Object? onboardingComplete = null,}) {
  return _then(Preferences(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,monthStartDay: null == monthStartDay ? _self.monthStartDay : monthStartDay // ignore: cast_nullable_to_non_nullable
as MonthStartDay,monthlyBudgetMinor: freezed == monthlyBudgetMinor ? _self.monthlyBudgetMinor : monthlyBudgetMinor // ignore: cast_nullable_to_non_nullable
as int?,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppTheme,dailyReminderOn: null == dailyReminderOn ? _self.dailyReminderOn : dailyReminderOn // ignore: cast_nullable_to_non_nullable
as bool,dailyReminderMinutes: null == dailyReminderMinutes ? _self.dailyReminderMinutes : dailyReminderMinutes // ignore: cast_nullable_to_non_nullable
as int,budgetAlertsOn: null == budgetAlertsOn ? _self.budgetAlertsOn : budgetAlertsOn // ignore: cast_nullable_to_non_nullable
as bool,weeklySummaryOn: null == weeklySummaryOn ? _self.weeklySummaryOn : weeklySummaryOn // ignore: cast_nullable_to_non_nullable
as bool,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthStartDayCopyWith<$Res> get monthStartDay {
  
  return $MonthStartDayCopyWith<$Res>(_self.monthStartDay, (value) {
    return _then(_self.copyWith(monthStartDay: value));
  });
}
}


/// Adds pattern-matching-related methods to [Preferences].
extension PreferencesPatterns on Preferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Preferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Preferences value)  $default,){
final _that = this;
switch (_that) {
case _Preferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Preferences value)?  $default,){
final _that = this;
switch (_that) {
case _Preferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userName,  String currencyCode,  MonthStartDay monthStartDay,  int? monthlyBudgetMinor,  AppTheme theme,  bool dailyReminderOn,  int dailyReminderMinutes,  bool budgetAlertsOn,  bool weeklySummaryOn,  bool onboardingComplete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.userName,_that.currencyCode,_that.monthStartDay,_that.monthlyBudgetMinor,_that.theme,_that.dailyReminderOn,_that.dailyReminderMinutes,_that.budgetAlertsOn,_that.weeklySummaryOn,_that.onboardingComplete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userName,  String currencyCode,  MonthStartDay monthStartDay,  int? monthlyBudgetMinor,  AppTheme theme,  bool dailyReminderOn,  int dailyReminderMinutes,  bool budgetAlertsOn,  bool weeklySummaryOn,  bool onboardingComplete)  $default,) {final _that = this;
switch (_that) {
case _Preferences():
return $default(_that.userName,_that.currencyCode,_that.monthStartDay,_that.monthlyBudgetMinor,_that.theme,_that.dailyReminderOn,_that.dailyReminderMinutes,_that.budgetAlertsOn,_that.weeklySummaryOn,_that.onboardingComplete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userName,  String currencyCode,  MonthStartDay monthStartDay,  int? monthlyBudgetMinor,  AppTheme theme,  bool dailyReminderOn,  int dailyReminderMinutes,  bool budgetAlertsOn,  bool weeklySummaryOn,  bool onboardingComplete)?  $default,) {final _that = this;
switch (_that) {
case _Preferences() when $default != null:
return $default(_that.userName,_that.currencyCode,_that.monthStartDay,_that.monthlyBudgetMinor,_that.theme,_that.dailyReminderOn,_that.dailyReminderMinutes,_that.budgetAlertsOn,_that.weeklySummaryOn,_that.onboardingComplete);case _:
  return null;

}
}

}

/// @nodoc


class _Preferences implements Preferences {
  const _Preferences({this.userName = '', this.currencyCode = 'MYR', this.monthStartDay = const DayOfMonth(1), this.monthlyBudgetMinor, this.theme = AppTheme.system, this.dailyReminderOn = true, this.dailyReminderMinutes = 21 * 60, this.budgetAlertsOn = true, this.weeklySummaryOn = false, this.onboardingComplete = false});
  

@override@JsonKey() final  String userName;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  MonthStartDay monthStartDay;
/// Null means no overall budget.
@override final  int? monthlyBudgetMinor;
@override@JsonKey() final  AppTheme theme;
@override@JsonKey() final  bool dailyReminderOn;
/// Minutes after local midnight; 21:00 by default (S07).
@override@JsonKey() final  int dailyReminderMinutes;
@override@JsonKey() final  bool budgetAlertsOn;
@override@JsonKey() final  bool weeklySummaryOn;
@override@JsonKey() final  bool onboardingComplete;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreferencesCopyWith<_Preferences> get copyWith => __$PreferencesCopyWithImpl<_Preferences>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Preferences&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.monthStartDay, monthStartDay) || other.monthStartDay == monthStartDay)&&(identical(other.monthlyBudgetMinor, monthlyBudgetMinor) || other.monthlyBudgetMinor == monthlyBudgetMinor)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.dailyReminderOn, dailyReminderOn) || other.dailyReminderOn == dailyReminderOn)&&(identical(other.dailyReminderMinutes, dailyReminderMinutes) || other.dailyReminderMinutes == dailyReminderMinutes)&&(identical(other.budgetAlertsOn, budgetAlertsOn) || other.budgetAlertsOn == budgetAlertsOn)&&(identical(other.weeklySummaryOn, weeklySummaryOn) || other.weeklySummaryOn == weeklySummaryOn)&&(identical(other.onboardingComplete, onboardingComplete) || other.onboardingComplete == onboardingComplete));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userName,currencyCode,monthStartDay,monthlyBudgetMinor,theme,dailyReminderOn,dailyReminderMinutes,budgetAlertsOn,weeklySummaryOn,onboardingComplete);
}

@override
String toString() {
    return 'Preferences(userName: $userName, currencyCode: $currencyCode, monthStartDay: $monthStartDay, monthlyBudgetMinor: $monthlyBudgetMinor, theme: $theme, dailyReminderOn: $dailyReminderOn, dailyReminderMinutes: $dailyReminderMinutes, budgetAlertsOn: $budgetAlertsOn, weeklySummaryOn: $weeklySummaryOn, onboardingComplete: $onboardingComplete)';
}


}

/// @nodoc
abstract mixin class _$PreferencesCopyWith<$Res> implements $PreferencesCopyWith<$Res> {
  factory _$PreferencesCopyWith(_Preferences value, $Res Function(_Preferences) _then) = __$PreferencesCopyWithImpl;
@override @useResult
$Res call({
 String userName, String currencyCode, MonthStartDay monthStartDay, int? monthlyBudgetMinor, AppTheme theme, bool dailyReminderOn, int dailyReminderMinutes, bool budgetAlertsOn, bool weeklySummaryOn, bool onboardingComplete
});


@override $MonthStartDayCopyWith<$Res> get monthStartDay;

}
/// @nodoc
class __$PreferencesCopyWithImpl<$Res>
    implements _$PreferencesCopyWith<$Res> {
  __$PreferencesCopyWithImpl(this._self, this._then);

  final _Preferences _self;
  final $Res Function(_Preferences) _then;

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userName = null,Object? currencyCode = null,Object? monthStartDay = null,Object? monthlyBudgetMinor = freezed,Object? theme = null,Object? dailyReminderOn = null,Object? dailyReminderMinutes = null,Object? budgetAlertsOn = null,Object? weeklySummaryOn = null,Object? onboardingComplete = null,}) {
  return _then(_Preferences(
userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,monthStartDay: null == monthStartDay ? _self.monthStartDay : monthStartDay // ignore: cast_nullable_to_non_nullable
as MonthStartDay,monthlyBudgetMinor: freezed == monthlyBudgetMinor ? _self.monthlyBudgetMinor : monthlyBudgetMinor // ignore: cast_nullable_to_non_nullable
as int?,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppTheme,dailyReminderOn: null == dailyReminderOn ? _self.dailyReminderOn : dailyReminderOn // ignore: cast_nullable_to_non_nullable
as bool,dailyReminderMinutes: null == dailyReminderMinutes ? _self.dailyReminderMinutes : dailyReminderMinutes // ignore: cast_nullable_to_non_nullable
as int,budgetAlertsOn: null == budgetAlertsOn ? _self.budgetAlertsOn : budgetAlertsOn // ignore: cast_nullable_to_non_nullable
as bool,weeklySummaryOn: null == weeklySummaryOn ? _self.weeklySummaryOn : weeklySummaryOn // ignore: cast_nullable_to_non_nullable
as bool,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Preferences
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MonthStartDayCopyWith<$Res> get monthStartDay {
  
  return $MonthStartDayCopyWith<$Res>(_self.monthStartDay, (value) {
    return _then(_self.copyWith(monthStartDay: value));
  });
}
}

// dart format on
