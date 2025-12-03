import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:checked_yaml/checked_yaml.dart';

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
      final yaml = File(results['yaml'] as String).readAsStringSync();
      try {
        config = checkedYamlDecode(
          yaml,
              (m) => configFromJson(m!),
          allowNull: false,
        );
      } on ParsedYamlException catch (e) {
        stderr.writeln(e.formattedMessage);
        exit(1);
      }
    }

    final bool pickedAny;
    try {
      (:config, :pickedAny) = merge(config, results);
      if (config == null) {
        print(parser.usage);
        exit(0);
      }
    } on ArgumentError catch (e) {
      stderr.writeln(e.toString());
      stderr.writeln(parser.usage);
      exit(1);
    }

    if (pickedAny) {
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String asYaml = encoder.convert(toJson(config));
      stderr.writeln(
        'To make this configuration reusable, copy/paste the following into a YAML file:',
      );
      stderr.writeln(asYaml);
    }

    return config;
  }

  void addOptions(ArgParser parser);

  C configFromJson(Map json);

  ({C? config, bool pickedAny}) merge(C? config, ArgResults results);

  Map<String, dynamic> toJson(C config);
}
