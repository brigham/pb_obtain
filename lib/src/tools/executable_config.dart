import 'package:freezed_annotation/freezed_annotation.dart';

import 'validate_exception.dart';

part 'executable_config.freezed.dart';
part 'executable_config.g.dart';

@freezed
@JsonSerializable()
class ExecutableConfig with _$ExecutableConfig {
  @override
  final String path;

  void validate() {
    if (path == "") {
      throw ValidateException("path", "cannot be empty.");
    }
  }

  const ExecutableConfig({required this.path});

  factory ExecutableConfig.fromJson(Map<String, dynamic> json) =>
      _$ExecutableConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ExecutableConfigToJson(this);
}
