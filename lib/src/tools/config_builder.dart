import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:checked_yaml/checked_yaml.dart';

class ConfigHelpException implements Exception {
  final String message;
  ConfigHelpException(this.message);

  @override
  String toString() => message;
}

class ConfigUserException implements Exception {
  final String message;
  ConfigUserException(this.message);

  @override
  String toString() => message;
}

abstract class ConfigBuilder<C> {
  final String? defaultYaml;

  ConfigBuilder(this.defaultYaml);

  C buildConfigOrExit(List<String> args) {
    try {
      return buildConfig(args);
    } on ConfigHelpException catch (e) {
      print(e.message);
      exit(0);
    } on ConfigUserException catch (e) {
      stderr.writeln(e.message);
      exit(1);
    }
  }

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

    final ArgResults results;
    try {
      results = parser.parse(args);
    } on ArgParserException catch (e) {
      throw ConfigUserException('${e.message}\n\n${parser.usage}');
    }

    if (results.flag('help')) {
      throw ConfigHelpException(parser.usage);
    }

    C? config;
    if ((results.option('yaml') ?? '').isNotEmpty) {
      final yaml = File(results['yaml'] as String).readAsStringSync();
      try {
        config = checkedYamlDecode(
          yaml,
          (m) => configFromJson(m!),
          allowNull: false,
        );
      } on ParsedYamlException catch (e) {
        throw ConfigUserException(e.formattedMessage ?? e.toString());
      }
    }

    final bool pickedAny;
    try {
      (:config, :pickedAny) = merge(config, results);
      if (config == null) {
        throw ConfigHelpException(parser.usage);
      }
    } on ArgumentError catch (e) {
      throw ConfigUserException('${e.toString()}\n\n${parser.usage}');
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

  C configFromJson(Map<dynamic, dynamic> json);

  ({C? config, bool pickedAny}) merge(C? config, ArgResults results);

  Map<String, dynamic> toJson(C config);
}
