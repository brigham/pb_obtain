import 'package:args/args.dart';

import 'config_builder.dart';
import 'launch_config.dart';

class LaunchConfigBuilder extends ConfigBuilder<LaunchConfig> {
  LaunchConfigBuilder() : super(null);

  @override
  void addOptions(ArgParser parser) => LaunchConfig.addOptions(parser);

  @override
  LaunchConfig configFromJson(Map json) => LaunchConfig.fromJson(json);

  @override
  ({LaunchConfig? config, bool pickedAny}) merge(
    LaunchConfig? config,
    ArgResults results,
  ) => LaunchConfig.merge(config, results, required: true);

  @override
  Map<String, dynamic> toJson(LaunchConfig config) => config.toJson();
}
