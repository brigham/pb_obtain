#! /usr/bin/env dcli

import 'package:pb_obtain/pb_obtain.dart';
import 'package:pb_obtain/src/tools/obtain_config_builder.dart';

void main(List<String> args) async {
  var builder = ObtainConfigBuilder();
  var config = builder.buildConfigOrExit(args);

  var executablePath = await obtain(config);
  print('Downloaded version ${config.githubTag} to $executablePath');
}
