#! /usr/bin/env dcli

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:pb_obtain/src/tools/executable_config.dart';
import 'package:pb_obtain/src/tools/launch.dart';
import 'package:pb_obtain/src/tools/launch_config.dart';
import 'package:pb_obtain/src/tools/obtain_config.dart';
import 'package:pb_obtain/src/tools/validate_exception.dart';
import 'package:yaml/yaml.dart';

void copyDirectoryContents(String sourceDir, String destDir) {
  if (!exists(sourceDir)) return;
  find('*', workingDirectory: sourceDir, recursive: false).forEach((file) {
    copy(file, destDir);
  });
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('yaml', abbr: 'y', help: 'YAML configuration file.')
    ..addOption(
      'template-dir',
      abbr: 'c',
      defaultsTo: 'pocketbase',
      help:
          'PocketBase template directory. pb_migrations, pb_hooks, and pb_public are copied to --output.',
    )
    ..addOption(
      'executable',
      abbr: 'x',
      defaultsTo: p.join(env['HOME']!, 'develop', 'pocketbase', 'pocketbase'),
      help: 'Path to PocketBase executable.',
    )
    ..addOption(
      'tag',
      abbr: 't',
      help:
          'PocketBase release to download, used instead of --executable if set.',
    )
    ..addOption(
      'download-dir',
      defaultsTo: p.join(env['HOME']!, 'develop', 'pocketbase'),
      help: 'Where to download binary specified by --tag.',
    )
    ..addOption(
      'home-dir',
      abbr: 'h',
      help:
          'The PocketBase home directory, where pb_data will be created and template files are copied.',
    )
    ..addOption(
      'port',
      abbr: 'p',
      defaultsTo: '8696',
      help: 'PocketBase port.',
    );

  final results = parser.parse(args);

  LaunchConfig? config;
  if (results['yaml'] != null) {
    final yaml = loadYaml(File(results['yaml'] as String).readAsStringSync());
    config = LaunchConfig.fromJson(yaml);
  }

  bool pickedAny = false;
  T? pickArg<T>(String name, T Function(String) converter) {
    if (config == null || results.wasParsed(name)) {
      pickedAny = true;
      return converter(results[name] as String);
    }
    return null;
  }

  String? pickString(String name) {
    return pickArg(name, (parsed) => parsed);
  }

  int? port = pickArg('port', (parsed) {
    final port = int.tryParse(parsed);
    if (port == null) {
      print('Invalid port number: $parsed');
      exit(1);
    }
    return port;
  });
  String? templateDir = pickString('template-dir');
  String? executable = pickString('executable');
  String? tag = pickString('tag');
  String? downloadDir = pickString('download-dir');
  String? homeDir = pickString('home-dir');

  config ??= LaunchConfig.empty();
  if (pickedAny) {
    config = config.copyWith(
      templateDir: templateDir ?? config.templateDir,
      executable: executable != null
          ? ExecutableConfig(path: executable)
          : config.executable,
      obtain: tag != null
          ? ObtainConfig(githubTag: tag, downloadDir: downloadDir!)
          : config.obtain,
      homeDirectory: homeDir ?? config.homeDirectory,
      port: port ?? config.port,
    );
    String asYaml = jsonEncode(config.toJson());
    stderr.writeln(
      "To make this configuration reusable, copy/paste the following into a YAML file:",
    );
    stderr.writeln(asYaml);
  }

  try {
    config.validate();
  } on ValidateException catch (e) {
    print(e);
    exit(1);
  }

  var process = await launch(config);

  await process.exitCode;
}
