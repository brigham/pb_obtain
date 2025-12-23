import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pb_obtain/src/tools/launch_exception.dart';

import 'launch_config.dart';
import 'obtain.dart';
import 'pocket_base_process.dart';

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

void _redirect(
  Stream<List<int>> stream,
  String? target, {
  required bool defaultToStdout,
}) {
  if (target == '/dev/null') {
    stream.drain<void>();
    return;
  }

  bool toStdout = defaultToStdout;
  if (target == '/dev/stdout') {
    toStdout = true;
  } else if (target == '/dev/stderr') {
    toStdout = false;
  } else if (target != null) {
    // File
    var mode = FileMode.write;
    var path = target;
    if (target.endsWith(':a')) {
      mode = FileMode.append;
      path = target.substring(0, target.length - 2);
    }
    final sink = File(path).openWrite(mode: mode);
    sink.addStream(stream).whenComplete(() => sink.close());
    return;
  }

  // Console
  if (toStdout) {
    stream.transform(SystemEncoding().decoder).listen(print);
  } else {
    stream.transform(SystemEncoding().decoder).listen(_log);
  }
}

Future<PocketBaseProcess> launch(
  LaunchConfig config, {
  http.Client? client,
}) async {
  final port = config.port;

  try {
    await http.get(Uri.parse('http://127.0.0.1:$port/api/health'));
    throw LaunchException('PocketBase is already running on port $port.');
  } on http.ClientException {
    // Good, we don't want a running server yet.
  }

  final templateDir = config.templateDir;

  final String executable;
  if (config.obtain != null) {
    executable = await obtain(config.obtain!);
  } else if (config.executable != null) {
    executable = config.executable!.path;
  } else {
    throw Exception('No way to find a PocketBase binary.');
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
  createSymLink(targetPath: p.absolute(executable), linkPath: pocketbaseLink);

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
  var httpHost = '127.0.0.1:$port';
  final process = await Process.start(p.join(pbDir, 'pocketbase'), [
    'serve',
    '--dir=${p.join(pbDir, 'pb_data')}',
    '--hooksDir=${p.join(pbDir, 'pb_hooks')}',
    '--publicDir=${p.join(pbDir, 'pb_public')}',
    '--migrationsDir=${p.join(pbDir, 'pb_migrations')}',
    '--http=$httpHost',
    if (config.devMode) '--dev',
  ], mode: mode);

  _redirect(process.stdout, config.stdout, defaultToStdout: true);
  _redirect(process.stderr, config.stderr, defaultToStdout: false);

  var pbProcess = PocketBaseProcess(process, httpHost);
  if (!await pbProcess.waitFor(.running, client: client)) {
    if (!await pbProcess.stop()) {
      pbProcess.process.kill(.sigkill);
      if (mode == .normal) {
        await pbProcess.process.exitCode;
      }
    }
    throw LaunchException('PocketBase failed to start in time.');
  }
  return pbProcess;
}
