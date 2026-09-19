// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'launch_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LaunchConfig {


/// Create a copy of LaunchConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaunchConfigCopyWith<LaunchConfig> get copyWith => _$LaunchConfigCopyWithImpl<LaunchConfig>(this as LaunchConfig, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LaunchConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaunchConfig&&(identical(other.templateDir, _this.templateDir) || other.templateDir == _this.templateDir)&&const DeepCollectionEquality().equals(other.templateDirs, _this.templateDirs)&&(identical(other.executable, _this.executable) || other.executable == _this.executable)&&(identical(other.obtain, _this.obtain) || other.obtain == _this.obtain)&&(identical(other.homeDirectory, _this.homeDirectory) || other.homeDirectory == _this.homeDirectory)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.detached, _this.detached) || other.detached == _this.detached)&&(identical(other.stdout, _this.stdout) || other.stdout == _this.stdout)&&(identical(other.stderr, _this.stderr) || other.stderr == _this.stderr)&&(identical(other.devMode, _this.devMode) || other.devMode == _this.devMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LaunchConfig;
  return Object.hash(runtimeType,_this.templateDir,const DeepCollectionEquality().hash(_this.templateDirs),_this.executable,_this.obtain,_this.homeDirectory,_this.port,_this.detached,_this.stdout,_this.stderr,_this.devMode);
}

@override
String toString() {
  final _this = this as LaunchConfig;
  return 'LaunchConfig(templateDir: ${_this.templateDir}, templateDirs: ${_this.templateDirs}, executable: ${_this.executable}, obtain: ${_this.obtain}, homeDirectory: ${_this.homeDirectory}, port: ${_this.port}, detached: ${_this.detached}, stdout: ${_this.stdout}, stderr: ${_this.stderr}, devMode: ${_this.devMode})';
}


}

/// @nodoc
abstract mixin class $LaunchConfigCopyWith<$Res>  {
  factory $LaunchConfigCopyWith(LaunchConfig value, $Res Function(LaunchConfig) _then) = _$LaunchConfigCopyWithImpl;
@useResult
$Res call({
 String templateDir, Map<String, List<String>> templateDirs, int port, bool detached, ExecutableConfig? executable, ObtainConfig? obtain, String? homeDirectory, String? stdout, String? stderr, bool devMode
});


$ExecutableConfigCopyWith<$Res>? get executable;$ObtainConfigCopyWith<$Res>? get obtain;

}
/// @nodoc
class _$LaunchConfigCopyWithImpl<$Res>
    implements $LaunchConfigCopyWith<$Res> {
  _$LaunchConfigCopyWithImpl(this._self, this._then);

  final LaunchConfig _self;
  final $Res Function(LaunchConfig) _then;

/// Create a copy of LaunchConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateDir = null,Object? templateDirs = null,Object? port = null,Object? detached = null,Object? executable = freezed,Object? obtain = freezed,Object? homeDirectory = freezed,Object? stdout = freezed,Object? stderr = freezed,Object? devMode = null,}) {
  return _then(LaunchConfig._(
templateDir: null == templateDir ? _self.templateDir : templateDir // ignore: cast_nullable_to_non_nullable
as String,templateDirs: null == templateDirs ? _self.templateDirs : templateDirs // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,detached: null == detached ? _self.detached : detached // ignore: cast_nullable_to_non_nullable
as bool,executable: freezed == executable ? _self.executable : executable // ignore: cast_nullable_to_non_nullable
as ExecutableConfig?,obtain: freezed == obtain ? _self.obtain : obtain // ignore: cast_nullable_to_non_nullable
as ObtainConfig?,homeDirectory: freezed == homeDirectory ? _self.homeDirectory : homeDirectory // ignore: cast_nullable_to_non_nullable
as String?,stdout: freezed == stdout ? _self.stdout : stdout // ignore: cast_nullable_to_non_nullable
as String?,stderr: freezed == stderr ? _self.stderr : stderr // ignore: cast_nullable_to_non_nullable
as String?,devMode: null == devMode ? _self.devMode : devMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of LaunchConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ExecutableConfigCopyWith<$Res>? get executable {
    if (_self.executable == null) {
    return null;
  }

  return $ExecutableConfigCopyWith<$Res>(_self.executable!, (value) {
    return _then(_self.copyWith(executable: value));
  });
}/// Create a copy of LaunchConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ObtainConfigCopyWith<$Res>? get obtain {
    if (_self.obtain == null) {
    return null;
  }

  return $ObtainConfigCopyWith<$Res>(_self.obtain!, (value) {
    return _then(_self.copyWith(obtain: value));
  });
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
