#! /usr/bin/env dcli

import 'package:args/args.dart';
import 'package:pb_obtain/src/tools/launch.dart';
import 'package:pb_obtain/src/tools/launch_config.dart';
import 'package:pb_obtain/src/tools/config_builder.dart';

class _LaunchConfigBuilder extends ConfigBuilder<LaunchConfig> {
  _LaunchConfigBuilder(): super(null);

  @override
  void addOptions(ArgParser parser) => LaunchConfig.addOptions(parser);

  @override
  LaunchConfig configFromJson(Map<String, dynamic> json) =>
      LaunchConfig.fromJson(json);

  @override
  ({LaunchConfig? config, bool pickedAny}) merge(
    LaunchConfig? config,
    ArgResults results,
  ) => LaunchConfig.merge(config, results);

  @override
  Map<String, dynamic> toJson(LaunchConfig config) => config.toJson();

  @override
  void validate(LaunchConfig config) => config.validate();
}

void main(List<String> args) async {
  var builder = _LaunchConfigBuilder();
  var config = builder.buildConfig(args);

  var process = await launch(config);

  if (!config.detached) {
    await process.process.exitCode;
  }
}
