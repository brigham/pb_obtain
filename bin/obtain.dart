#! /usr/bin/env dcli

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:pb_obtain/src/tools/obtain_config.dart';
import 'package:pb_obtain/src/tools/obtain.dart';
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
      'tag',
      abbr: 't',
      help:
          'PocketBase release to download, used instead of --executable if set.',
    )
    ..addOption(
      'release-dir',
      abbr: 'r',
      defaultsTo: p.join(env['HOME']!, 'develop', 'pocketbase'),
      help: 'Where to download binary specified by --tag.',
    );

  final results = parser.parse(args);

  ObtainConfig? config;
  if (results['yaml'] != null) {
    final yaml = loadYaml(File(results['yaml'] as String).readAsStringSync());
    config = ObtainConfig.fromJson(yaml);
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

  String? version = pickString('tag');
  String? releaseDir = pickString('release-dir');

  config ??= ObtainConfig.empty();
  if (pickedAny) {
    config = config.copyWith(
        githubTag: version ?? config.githubTag,
        downloadDir: releaseDir ?? config.downloadDir
    );
    String asYaml = jsonEncode(config.toJson());
    stderr.writeln('To make this configuration reusable, copy/paste the following into a YAML file:');
    stderr.writeln(asYaml);
  }

  try {
    config.validate();
  } on ValidateException catch (e) {
    print(e);
    exit(1);
  }

  var executablePath = await obtain(config);
  print('Downloaded version ${config.githubTag} to $executablePath');
}
