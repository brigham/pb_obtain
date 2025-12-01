// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launch_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LaunchConfig {

 String get templateDir; ExecutableConfig? get executable; ObtainConfig? get obtain; String? get homeDirectory; int get port; bool get detached;
/// Create a copy of LaunchConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchConfigCopyWith<LaunchConfig> get copyWith => _$LaunchConfigCopyWithImpl<LaunchConfig>(this as LaunchConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchConfig&&(identical(other.templateDir, templateDir) || other.templateDir == templateDir)&&(identical(other.executable, executable) || other.executable == executable)&&(identical(other.obtain, obtain) || other.obtain == obtain)&&(identical(other.homeDirectory, homeDirectory) || other.homeDirectory == homeDirectory)&&(identical(other.port, port) || other.port == port)&&(identical(other.detached, detached) || other.detached == detached));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,templateDir,executable,obtain,homeDirectory,port,detached);

@override
String toString() {
  return 'LaunchConfig(templateDir: $templateDir, executable: $executable, obtain: $obtain, homeDirectory: $homeDirectory, port: $port, detached: $detached)';
}


}

/// @nodoc
abstract mixin class $LaunchConfigCopyWith<$Res>  {
  factory $LaunchConfigCopyWith(LaunchConfig value, $Res Function(LaunchConfig) _then) = _$LaunchConfigCopyWithImpl;
@useResult
$Res call({
 String templateDir, int port, bool detached, ExecutableConfig? executable, ObtainConfig? obtain, String? homeDirectory
});




}
/// @nodoc
class _$LaunchConfigCopyWithImpl<$Res>
    implements $LaunchConfigCopyWith<$Res> {
  _$LaunchConfigCopyWithImpl(this._self, this._then);

  final LaunchConfig _self;
  final $Res Function(LaunchConfig) _then;

/// Create a copy of LaunchConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateDir = null,Object? port = null,Object? detached = null,Object? executable = freezed,Object? obtain = freezed,Object? homeDirectory = freezed,}) {
  return _then(LaunchConfig._(
templateDir: null == templateDir ? _self.templateDir : templateDir // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,detached: null == detached ? _self.detached : detached // ignore: cast_nullable_to_non_nullable
as bool,executable: freezed == executable ? _self.executable : executable // ignore: cast_nullable_to_non_nullable
as ExecutableConfig?,obtain: freezed == obtain ? _self.obtain : obtain // ignore: cast_nullable_to_non_nullable
as ObtainConfig?,homeDirectory: freezed == homeDirectory ? _self.homeDirectory : homeDirectory // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LaunchConfig].
extension LaunchConfigPatterns on LaunchConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
