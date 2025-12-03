#! /usr/bin/env dcli

import 'package:pb_obtain/src/tools/launch.dart';
import 'package:pb_obtain/src/tools/launch_config_builder.dart';

void main(List<String> args) async {
  var builder = LaunchConfigBuilder();
  var config = builder.buildConfigOrExit(args);

  var process = await launch(config);

  if (!config.detached) {
    await process.process.exitCode;
  }
}
