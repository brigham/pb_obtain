import 'package:freezed_annotation/freezed_annotation.dart';

import 'validate_exception.dart';

part 'obtain_config.g.dart';
part 'obtain_config.freezed.dart';

/// Configuration for downloading the PocketBase executable.
///
/// This class specifies the version of PocketBase to download and the directory
/// where the downloaded executable should be stored.
@freezed
@JsonSerializable()
class ObtainConfig with _$ObtainConfig {
  /// The GitHub release tag of the PocketBase version to download (e.g., "v0.16.10").
  @override
  final String githubTag;

  /// The directory where the PocketBase executable will be downloaded and extracted.
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

  /// Creates a configuration for obtaining PocketBase.
  const ObtainConfig({required this.githubTag, required this.downloadDir});

  /// Creates an empty configuration with empty strings.
  const ObtainConfig.empty() : this(githubTag: "", downloadDir: "");

  /// Creates an [ObtainConfig] from a JSON map.
  factory ObtainConfig.fromJson(Map<String, dynamic> json) =>
      _$ObtainConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ObtainConfigToJson(this);
}
