import 'package:freezed_annotation/freezed_annotation.dart';

part 'executable_config.freezed.dart';
part 'executable_config.g.dart';

/// Configuration for using an existing PocketBase executable.
///
/// This class holds the path to a local PocketBase binary that should be used
/// instead of downloading one.
@freezed
@JsonSerializable(anyMap: true, checked: true, disallowUnrecognizedKeys: true)
class ExecutableConfig with _$ExecutableConfig {
  /// The file path to the PocketBase executable.
  @override
  final String path;

  void _validate() {
    if (path.isEmpty) {
      throw ArgumentError.value(path, 'path', 'cannot be empty.');
    }
  }

  /// Creates a configuration for an existing PocketBase executable.
  ExecutableConfig({required this.path}) {
    _validate();
  }

  /// Creates an [ExecutableConfig] from a JSON map.
  factory ExecutableConfig.fromJson(Map json) =>
      _$ExecutableConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ExecutableConfigToJson(this);
}
