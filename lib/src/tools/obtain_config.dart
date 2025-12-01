import 'package:freezed_annotation/freezed_annotation.dart';

import 'validate_exception.dart';

part 'obtain_config.g.dart';
part 'obtain_config.freezed.dart';

@freezed
@JsonSerializable()
class ObtainConfig with _$ObtainConfig {
  @override
  final String githubTag;
  @override
  final String downloadDir;

  void validate() {
    if (githubTag == "") {
      throw ValidateException("githubTag", "cannot be empty.");
    }
    if (downloadDir == "") {
      throw ValidateException("downloadPath", "cannot be empty.");
    }
  }

  const ObtainConfig({required this.githubTag, required this.downloadDir});

  const ObtainConfig.empty() : this(githubTag: "", downloadDir: "");

  factory ObtainConfig.fromJson(Map<String, dynamic> json) =>
      _$ObtainConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ObtainConfigToJson(this);
}
