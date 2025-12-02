import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pb_obtain/pb_obtain.dart';
import 'package:test/test.dart';

void main() {
  group('launch', () {
    late Directory tempDir;
    late Directory templateDir;
    late String dummyExecutablePath;
    Process? process;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('launch_test_');
      templateDir = Directory(p.join(tempDir.path, 'templates'))..createSync();

      // Create subdirectories in templateDir to be copied
      Directory(p.join(templateDir.path, 'pb_migrations')).createSync();
      Directory(p.join(templateDir.path, 'pb_hooks')).createSync();
      Directory(p.join(templateDir.path, 'pb_public')).createSync();
      Directory(p.join(templateDir.path, 'dev_migrations')).createSync();

      // Create a dummy file in pb_public to verify copy
      File(
        p.join(templateDir.path, 'pb_public', 'index.html'),
      ).writeAsStringSync('Hello');

      // Create dummy executable script
      dummyExecutablePath = p.join(tempDir.path, 'dummy_pb.sh');
      final scriptContent = '''
#!/bin/sh
echo "Dummy PocketBase started"
echo "Args: \$@"
# Keep running for a bit to allow detection
sleep 5
''';
      File(dummyExecutablePath).writeAsStringSync(scriptContent);
      Process.runSync('chmod', ['+x', dummyExecutablePath]);
    });

    tearDown(() {
      process?.kill();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('launches process and sets up directories (temp data dir)', () async {
      final config = LaunchConfig.executable(
        templateDir: templateDir.path,
        port: 8090,
        detached: false,
        executable: ExecutableConfig(path: dummyExecutablePath),
      );

      process = await launch(config);

      // Give it a moment to run
      await Future.delayed(Duration(milliseconds: 500));

      expect(process, isNotNull);
      expect(process!.pid, greaterThan(0));

      // Verify it's running
      bool isDone = false;
      process!.exitCode.then((_) => isDone = true);
      await Future.delayed(Duration(milliseconds: 100));
      expect(isDone, isFalse, reason: "Process should still be running");
    });

    test('launches process and sets up directories (specified data dir)', () async {
      final dataDir = Directory(p.join(tempDir.path, 'data'));

      final config = LaunchConfig.executable(
        templateDir: templateDir.path,
        port: 8090,
        detached: false,
        executable: ExecutableConfig(path: dummyExecutablePath),
        homeDirectory: dataDir.path,
      );

      process = await launch(config);

      // Give the process a moment to start
      await Future.delayed(Duration(milliseconds: 100));

      // Verify directories
      expect(dataDir.existsSync(), isTrue);
      expect(Directory(p.join(dataDir.path, 'pb_data')).existsSync(), isTrue);
      expect(Directory(p.join(dataDir.path, 'pb_hooks')).existsSync(), isTrue);
      expect(Directory(p.join(dataDir.path, 'pb_public')).existsSync(), isTrue);
      expect(
        Directory(p.join(dataDir.path, 'pb_migrations')).existsSync(),
        isTrue,
      );

      // Verify file copy
      expect(
        File(p.join(dataDir.path, 'pb_public', 'index.html')).existsSync(),
        isTrue,
      );

      // Verify symlink
      final symlink = Link(p.join(dataDir.path, 'pocketbase'));
      expect(symlink.existsSync(), isTrue);
      expect(symlink.targetSync(), dummyExecutablePath);

      // Verify process is running (should rely on the fact that launch returned)
      // We can check if exitCode completes immediately (meaning it failed or finished)
      // Since our script sleeps for 5s, it should not be done yet.
      bool isDone = false;
      process!.exitCode.then((_) => isDone = true);
      await Future.delayed(Duration(milliseconds: 100));
      expect(isDone, isFalse, reason: "Process should still be running");
    });
  });
}
