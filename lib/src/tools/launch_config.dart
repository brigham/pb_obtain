import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;

import 'arg_picker.dart';
import 'executable_config.dart';
import 'obtain_config.dart';

part 'launch_config.freezed.dart';
part 'launch_config.g.dart';

/// Configuration for launching the PocketBase server.
///
/// This class defines how PocketBase should be started, including where to find
/// or download the executable, where to store data, and what port to listen on.
@freezed
@JsonSerializable(
  constructor: '_',
  anyMap: true,
  checked: true,
  disallowUnrecognizedKeys: true,
)
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

  /// Where to redirect stdout.
  ///
  /// Can be `/dev/stdout`, `/dev/stderr`, `/dev/null`, or a file path.
  /// If a file path ends with `:a`, output will be appended.
  @override
  final String? stdout;

  /// Where to redirect stderr.
  ///
  /// Can be `/dev/stdout`, `/dev/stderr`, `/dev/null`, or a file path.
  /// If a file path ends with `:a`, output will be appended.
  @override
  final String? stderr;

  void _validate() {
    if (templateDir == '') {
      throw ArgumentError.value(templateDir, 'templateDir', 'cannot be empty');
    }
    if (executable == null && obtain == null) {
      throw ArgumentError.value(
        executable,
        'executable',
        'executable or obtain must be set',
      );
    }
    if (executable != null && obtain != null) {
      throw ArgumentError.value(
        executable,
        'executable',
        'cannot be set with obtain',
      );
    }
    if (port == 0) {
      throw ArgumentError.value(port, 'port', 'must be set to non-zero.');
    }
  }

  /// Creates a raw launch configuration.
  ///
  /// Usually, [LaunchConfig.executable] or [LaunchConfig.obtain] should be used instead.
  LaunchConfig._({
    required this.templateDir,
    required this.port,
    required this.detached,
    this.executable,
    this.obtain,
    this.homeDirectory,
    this.stdout,
    this.stderr,
  }) {
    _validate();
  }

  /// Creates an empty launch configuration with default values.
  LaunchConfig.empty()
    : templateDir = '',
      port = 0,
      detached = false,
      executable = null,
      obtain = null,
      homeDirectory = null,
      stdout = null,
      stderr = null;

  /// Creates a launch configuration using an existing PocketBase executable.
  LaunchConfig.executable({
    required this.templateDir,
    required this.port,
    required this.detached,
    required ExecutableConfig this.executable,
    this.homeDirectory,
    this.stdout,
    this.stderr,
  }) : obtain = null {
    _validate();
  }

  /// Creates a launch configuration that downloads PocketBase.
  LaunchConfig.obtain({
    required this.templateDir,
    required this.port,
    required this.detached,
    required ObtainConfig this.obtain,
    this.homeDirectory,
    this.stdout,
    this.stderr,
  }) : executable = null {
    _validate();
  }

  /// Creates a [LaunchConfig] from a JSON map.
  factory LaunchConfig.fromJson(Map json) => _$LaunchConfigFromJson(json);

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
      ..addOption('port', defaultsTo: '8696', help: 'PocketBase port.')
      ..addOption(
        'stdout',
        help:
            'Where to redirect stdout. Options: /dev/stdout, /dev/stderr, /dev/null, or a file path. Append with :a to append to file.',
      )
      ..addOption(
        'stderr',
        help:
            'Where to redirect stderr. Options: /dev/stdout, /dev/stderr, /dev/null, or a file path. Append with :a to append to file.',
      );
  }

  static ({LaunchConfig? config, bool pickedAny}) merge(
    LaunchConfig? config,
    ArgResults results, {
    bool required = true,
  }) {
    var picker = ArgPicker(config, results);

    int? port = picker.pickArg('port', (parsed) {
      final port = int.tryParse(parsed);
      if (port == null) {
        throw ArgumentError.value(parsed, 'port', 'must be a number');
      }
      return port;
    });
    String? templateDir = picker.pickString('template-dir');
    String? executable = picker.pickString('executable');
    String? homeDir = picker.pickString('home-dir');
    String? stdout = picker.pickString('stdout');
    String? stderr = picker.pickString('stderr');

    var (config: mergedObtain, pickedAny: obtainPickedAny) = ObtainConfig.merge(
      config?.obtain,
      results,
      required: false,
    );
    if (mergedObtain != null && !results.wasParsed('executable')) {
      executable = null;
    }

    if (!required &&
        config == null &&
        homeDir == null &&
        mergedObtain == null &&
        stdout == null &&
        stderr == null) {
      return (config: null, pickedAny: picker.pickedAny);
    }

    var pickedAny = picker.pickedAny || obtainPickedAny;
    if (pickedAny) {
      config ??= LaunchConfig.empty();
      config = config.copyWith(
        templateDir: templateDir ?? config.templateDir,
        executable: executable != null
            ? ExecutableConfig(path: executable)
            : config.executable,
        obtain: mergedObtain,
        homeDirectory: homeDir ?? config.homeDirectory,
        port: port ?? config.port,
        stdout: stdout ?? config.stdout,
        stderr: stderr ?? config.stderr,
      );
    }

    return (config: config, pickedAny: pickedAny);
  }
}
