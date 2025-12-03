import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'validate_exception.dart';

abstract class ConfigBuilder<C> {
  final String? defaultYaml;

  ConfigBuilder(this.defaultYaml);

  C buildConfig(List<String> args) {
    final parser = ArgParser(usageLineLength: 80)
      ..addOption(
        'yaml',
        abbr: 'y',
        defaultsTo: defaultYaml,
        help: 'YAML configuration file.',
      )
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help.');
    addOptions(parser);

    final results = parser.parse(args);
    if (results['help']) {
      print(parser.usage);
      exit(0);
    }

    C? config;
    if (results['yaml'] != null) {
      final yaml =
          loadYaml(File(results['yaml'] as String).readAsStringSync())
              as YamlMap;
      config = configFromJson(yaml.cast());
    }

    final bool pickedAny;
    (:config, :pickedAny) = merge(config, results);
    if (config == null) {
      print(parser.usage);
      exit(0);
    }

    try {
      validate(config);
    } on ValidateException catch (e) {
      print(e);
      print(parser.usage);
      exit(1);
    }

    if (pickedAny) {
      String asYaml = jsonEncode(toJson(config));
      stderr.writeln(
        'To make this configuration reusable, copy/paste the following into a YAML file:',
      );
      stderr.writeln(asYaml);
    }

    return config;
  }

  void addOptions(ArgParser parser);

  C configFromJson(Map<String, dynamic> json);

  ({C? config, bool pickedAny}) merge(C? config, ArgResults results);

  void validate(C config);

  Map<String, dynamic> toJson(C config);
}
