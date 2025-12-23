import 'package:args/args.dart';

import 'config_builder.dart';
import 'obtain_config.dart';

class ObtainConfigBuilder extends ConfigBuilder<ObtainConfig> {
  ObtainConfigBuilder() : super(null);

  @override
  void addOptions(ArgParser parser) => ObtainConfig.addOptions(parser);

  @override
  ObtainConfig configFromJson(Map<dynamic, dynamic> json) =>
      ObtainConfig.fromJson(json);

  @override
  ({ObtainConfig? config, bool pickedAny}) merge(
    ObtainConfig? config,
    ArgResults results,
  ) => ObtainConfig.merge(config, results, required: true);

  @override
  Map<String, dynamic> toJson(ObtainConfig config) {
    return config.toJson();
  }
}
