#! /usr/bin/env dcli

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:pb_obtain/pb_obtain.dart';
import 'package:pb_obtain/src/tools/obtain_config_builder.dart';

void main(List<String> args) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) => stderr.writeln(record.message));

  var builder = ObtainConfigBuilder();
  var config = builder.buildConfigOrExit(args);

  var executablePath = await obtain(config);
  print('Downloaded version ${config.githubTag} to $executablePath');
}
