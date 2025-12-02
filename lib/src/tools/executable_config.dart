import 'package:freezed_annotation/freezed_annotation.dart';

import 'validate_exception.dart';

part 'executable_config.freezed.dart';
part 'executable_config.g.dart';

/// Configuration for using an existing PocketBase executable.
///
/// This class holds the path to a local PocketBase binary that should be used
/// instead of downloading one.
@freezed
@JsonSerializable()
class ExecutableConfig with _$ExecutableConfig {
  /// The file path to the PocketBase executable.
  @override
  final String path;

  void validate() {
    if (path == "") {
      throw ValidateException("path", "cannot be empty.");
    }
  }

  /// Creates a configuration for an existing PocketBase executable.
  const ExecutableConfig({required this.path});

  /// Creates an [ExecutableConfig] from a JSON map.
  factory ExecutableConfig.fromJson(Map<String, dynamic> json) =>
      _$ExecutableConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ExecutableConfigToJson(this);
}
