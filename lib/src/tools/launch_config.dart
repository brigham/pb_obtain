import 'package:freezed_annotation/freezed_annotation.dart';
import 'obtain_config.dart';
import 'validate_exception.dart';

import 'executable_config.dart';

part 'launch_config.freezed.dart';
part 'launch_config.g.dart';

@freezed
@JsonSerializable(constructor: '_')
class LaunchConfig with _$LaunchConfig {
  @override
  final String templateDir;
  @override
  final ExecutableConfig? executable;
  @override
  final ObtainConfig? obtain;
  @override
  final String? homeDirectory;
  @override
  final int port;
  @override
  final bool detached;

  void validate() {
    if (templateDir == "") {
      throw ValidateException("template", "template cannot be empty.");
    }
    if (executable == null && obtain == null) {
      throw ValidateException("executable/obtain", "one must be set");
    }
    if (executable != null && obtain != null) {
      throw ValidateException("executable", "cannot be set with obtain");
    }
    ValidateException.usingPrefix("executable", () {
      executable?.validate();
    });
    ValidateException.usingPrefix("obtain", () {
      obtain?.validate();
    });
    if (port == 0) {
      throw ValidateException("port", "must be set to non-zero.");
    }
  }

  const LaunchConfig._({
    required this.templateDir,
    required this.port,
    required this.detached,
    this.executable,
    this.obtain,
    this.homeDirectory,
  });

  const LaunchConfig.empty() : this._(templateDir: "", port: 0, detached: false);

  const LaunchConfig.executable({
    required this.templateDir,
    required this.port,
    required this.detached,
    required ExecutableConfig this.executable,
    this.homeDirectory,
  }) : obtain = null;

  const LaunchConfig.obtain({
    required this.templateDir,
    required this.port,
    required this.detached,
    required ObtainConfig this.obtain,
    this.homeDirectory,
  }) : executable = null;

  factory LaunchConfig.fromJson(Map<String, dynamic> json) =>
      _$LaunchConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LaunchConfigToJson(this);
}
