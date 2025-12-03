#! /usr/bin/env dcli

import 'package:args/args.dart';
import 'package:pb_obtain/pb_obtain.dart';
import 'package:pb_obtain/src/tools/config_builder.dart';

class _ObtainConfigBuilder extends ConfigBuilder<ObtainConfig> {
  _ObtainConfigBuilder() : super(null);

  @override
  void addOptions(ArgParser parser) => ObtainConfig.addOptions(parser);

  @override
  ObtainConfig configFromJson(Map json) => ObtainConfig.fromJson(json);

  @override
  ({ObtainConfig? config, bool pickedAny}) merge(
    ObtainConfig? config,
    ArgResults results,
  ) => ObtainConfig.merge(config, results);

  @override
  Map<String, dynamic> toJson(ObtainConfig config) {
    return config.toJson();
  }
}

void main(List<String> args) async {
  var builder = _ObtainConfigBuilder();
  var config = builder.buildConfig(args);

  var executablePath = await obtain(config);
  print('Downloaded version ${config.githubTag} to $executablePath');
}
