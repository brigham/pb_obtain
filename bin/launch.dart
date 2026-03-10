#! /usr/bin/env dcli

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:pb_obtain/src/tools/launch.dart';
import 'package:pb_obtain/src/tools/launch_config_builder.dart';

void main(List<String> args) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) => stderr.writeln(record.message));

  var builder = LaunchConfigBuilder();
  var config = builder.buildConfigOrExit(args);

  var process = await launch(config);

  if (!config.detached) {
    await process.process.exitCode;
  }
}
