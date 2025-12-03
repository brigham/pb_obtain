import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;

import 'arg_picker.dart';
import 'executable_config.dart';
import 'obtain_config.dart';
import 'validate_exception.dart';

part 'launch_config.freezed.dart';
part 'launch_config.g.dart';

/// Configuration for launching the PocketBase server.
///
/// This class defines how PocketBase should be started, including where to find
/// or download the executable, where to store data, and what port to listen on.
@freezed
@JsonSerializable(constructor: '_')
class LaunchConfig with _$LaunchConfig {
  /// The directory containing PocketBase template files.
  ///
  /// Subdirectories `pb_migrations`, `pb_hooks`, and `pb_public` from this
  /// directory will be copied to the PocketBase working directory.
  @override
  final String templateDir;

  /// Configuration for using an existing PocketBase executable.
  ///
  /// This is mutually exclusive with [obtain].
  @override
  final ExecutableConfig? executable;

  /// Configuration for downloading the PocketBase executable.
  ///
  /// This is mutually exclusive with [executable].
  @override
  final ObtainConfig? obtain;

  /// The directory where PocketBase data will be stored.
  ///
  /// If provided, the `pb_data` directory will be created inside this path.
  /// If `null`, a temporary directory will be created and used.
  @override
  final String? homeDirectory;

  /// The port number the PocketBase server should listen on.
  ///
  /// This must be a non-zero integer.
  @override
  final int port;

  /// Whether to run the PocketBase process in detached mode.
  ///
  /// If `true`, the process is started with `ProcessStartMode.detachedWithStdio`.
  /// If `false`, it runs with `ProcessStartMode.normal`.
  @override
  final bool detached;

  void validate() {
    if (templateDir == '') {
      throw ValidateException('template', 'template cannot be empty.');
    }
    if (executable == null && obtain == null) {
      throw ValidateException('executable/obtain', 'one must be set');
    }
    if (executable != null && obtain != null) {
      throw ValidateException('executable', 'cannot be set with obtain');
    }
    ValidateException.usingPrefix('executable', () {
      executable?.validate();
    });
    ValidateException.usingPrefix('obtain', () {
      obtain?.validate();
    });
    if (port == 0) {
      throw ValidateException('port', 'must be set to non-zero.');
    }
  }

  /// Creates a raw launch configuration.
  ///
  /// Usually, [LaunchConfig.executable] or [LaunchConfig.obtain] should be used instead.
  const LaunchConfig._({
    required this.templateDir,
    required this.port,
    required this.detached,
    this.executable,
    this.obtain,
    this.homeDirectory,
  });

  /// Creates an empty launch configuration with default values.
  const LaunchConfig.empty()
    : this._(templateDir: '', port: 0, detached: false);

  /// Creates a launch configuration using an existing PocketBase executable.
  const LaunchConfig.executable({
    required this.templateDir,
    required this.port,
    required this.detached,
    required ExecutableConfig this.executable,
    this.homeDirectory,
  }) : obtain = null;

  /// Creates a launch configuration that downloads PocketBase.
  const LaunchConfig.obtain({
    required this.templateDir,
    required this.port,
    required this.detached,
    required ObtainConfig this.obtain,
    this.homeDirectory,
  }) : executable = null;

  /// Creates a [LaunchConfig] from a JSON map.
  factory LaunchConfig.fromJson(Map<String, dynamic> json) =>
      _$LaunchConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LaunchConfigToJson(this);

  static void addOptions(ArgParser parser) {
    parser
      ..addSeparator(
        '''
Where to find the binary
========================
Use a local executable or download from GitHub.'''
            .trim(),
      )
      ..addSeparator(
        '''
Local executable
----------------'''
            .trim(),
      )
      ..addOption(
        'executable',
        defaultsTo: p.join(env['HOME']!, 'develop', 'pocketbase', 'pocketbase'),
        help: 'Path to PocketBase executable.',
      )
      ..addSeparator(
        '''
Download from GitHub
--------------------'''
            .trim(),
      );
    ObtainConfig.addOptions(parser);

    parser
      ..addSeparator(
        '''
Launch settings
==============='''
            .trim(),
      )
      ..addOption(
        'template-dir',
        defaultsTo: 'pocketbase',
        help:
            'PocketBase template directory. pb_migrations, pb_hooks, and pb_public are copied to --output.',
      )
      ..addOption(
        'home-dir',
        help:
            'The PocketBase home directory, where pb_data will be created and template files are copied.',
      )
      ..addOption('port', defaultsTo: '8696', help: 'PocketBase port.');
  }

  static ({LaunchConfig? config, bool pickedAny}) merge(
    LaunchConfig? config,
    ArgResults results,
  ) {
    var picker = ArgPicker(config, results);

    int? port = picker.pickArg('port', (parsed) {
      final port = int.tryParse(parsed);
      if (port == null) {
        throw ValidateException('port', 'must be a number: $parsed');
      }
      return port;
    });
    String? templateDir = picker.pickString('template-dir');
    String? executable = picker.pickString('executable');
    String? homeDir = picker.pickString('home-dir');

    if (picker.pickedAny) {
      config ??= LaunchConfig.empty();
      config = config.copyWith(
        templateDir: templateDir ?? config.templateDir,
        executable: executable != null
            ? ExecutableConfig(path: executable)
            : config.executable,
        obtain: ObtainConfig.merge(config.obtain, results).config,
        homeDirectory: homeDir ?? config.homeDirectory,
        port: port ?? config.port,
      );
    } else if (config == null) {
      return (config: null, pickedAny: picker.pickedAny);
    }

    return (config: config, pickedAny: picker.pickedAny);
  }
}
