import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;

import 'arg_picker.dart';
import 'validate_exception.dart';

part 'obtain_config.freezed.dart';
part 'obtain_config.g.dart';

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
    if (githubTag == '') {
      throw ValidateException('githubTag', 'cannot be empty.');
    }
    if (downloadDir == '') {
      throw ValidateException('downloadPath', 'cannot be empty.');
    }
  }

  /// Creates a configuration for obtaining PocketBase.
  const ObtainConfig({required this.githubTag, required this.downloadDir});

  /// Creates an empty configuration with empty strings.
  const ObtainConfig.empty() : this(githubTag: '', downloadDir: '');

  /// Creates an [ObtainConfig] from a JSON map.
  factory ObtainConfig.fromJson(Map<String, dynamic> json) =>
      _$ObtainConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ObtainConfigToJson(this);

  static void addOptions(ArgParser parser) {
    parser
      ..addOption('tag', help: 'PocketBase release to download.')
      ..addOption(
        'release-dir',
        defaultsTo: p.join(env['HOME']!, 'develop', 'pocketbase'),
        help: 'Where to download binary specified by --tag.',
      );
  }

  static ({ObtainConfig? config, bool pickedAny}) merge(
    ObtainConfig? config,
    ArgResults results,
  ) {
    var picker = ArgPicker(config, results);

    String? version = picker.pickString('tag');
    String? releaseDir = picker.pickString('release-dir');

    if (picker.pickedAny) {
      config = config ?? ObtainConfig.empty();
      config = config.copyWith(
        githubTag: version ?? config.githubTag,
        downloadDir: releaseDir ?? config.downloadDir,
      );
    } else if (config == null) {
      return (config: null, pickedAny: picker.pickedAny);
    }

    return (config: config, pickedAny: picker.pickedAny);
  }
}
