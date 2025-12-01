import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;

import 'launch_config.dart';
import 'obtain.dart';

void copyDirectoryContents(String sourceDir, String destDir) {
  if (!exists(sourceDir)) return;
  find('*', workingDirectory: sourceDir, recursive: false).forEach((file) {
    copy(file, destDir, overwrite: true);
  });
}

void _createDirIfNotExists(String path, {bool recursive = false}) {
  if (!exists(path)) {
    createDir(path, recursive: recursive);
  }
}

void _log(String message) {
  stderr.writeln(message);
}

Future<Process> launch(LaunchConfig config) async {
  final port = config.port;
  final templateDir = config.templateDir;

  final String executable;
  if (config.obtain != null) {
    executable = await obtain(config.obtain!);
  } else if (config.executable != null) {
    executable = config.executable!.path;
  } else {
    throw Exception("No way to find a PocketBase binary.");
  }

  final dataDirectory = config.homeDirectory;

  String pbDir;
  bool tempDir = false;
  if (dataDirectory == null) {
    pbDir = Directory.systemTemp.createTempSync('pocketbase_').path;
    _log('Created temporary PocketBase directory at $pbDir');
    tempDir = true;
  } else {
    pbDir = dataDirectory;
    if (!exists(pbDir)) {
      createDir(pbDir, recursive: true);
    }
    _log('Using PocketBase directory at $pbDir');
  }

  _createDirIfNotExists(p.join(pbDir, 'pb_data'), recursive: true);
  _createDirIfNotExists(p.join(pbDir, 'pb_hooks'), recursive: true);
  _createDirIfNotExists(p.join(pbDir, 'pb_public'), recursive: true);
  _createDirIfNotExists(p.join(pbDir, 'pb_migrations'), recursive: true);

  final pocketbaseLink = p.join(pbDir, 'pocketbase');
  if (exists(pocketbaseLink)) {
    delete(pocketbaseLink);
  }
  createSymLink(targetPath: executable, linkPath: pocketbaseLink);

  copyDirectoryContents(
    p.join(templateDir, 'pb_migrations'),
    p.join(pbDir, 'pb_migrations'),
  );

  if (tempDir) {
    copyDirectoryContents(
      p.join(templateDir, 'dev_migrations'),
      p.join(pbDir, 'pb_migrations'),
    );
  }

  copyDirectoryContents(
    p.join(templateDir, 'pb_hooks'),
    p.join(pbDir, 'pb_hooks'),
  );

  copyDirectoryContents(
    p.join(templateDir, 'pb_public'),
    p.join(pbDir, 'pb_public'),
  );

  ProcessStartMode mode = config.detached ? .detachedWithStdio : .normal;
  final process = await Process.start(p.join(pbDir, 'pocketbase'), [
    'serve',
    '--dir=${p.join(pbDir, 'pb_data')}',
    '--hooksDir=${p.join(pbDir, 'pb_hooks')}',
    '--publicDir=${p.join(pbDir, 'pb_public')}',
    '--migrationsDir=${p.join(pbDir, 'pb_migrations')}',
    '--http=127.0.0.1:$port',
  ], mode: mode);

  process.stdout.transform(SystemEncoding().decoder).listen(print);
  process.stderr.transform(SystemEncoding().decoder).listen(_log);

  return process;
}
