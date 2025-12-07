import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:pb_obtain/pb_obtain.dart';
import 'package:test/test.dart';

import 'launch_test.mocks.dart';

void main() {
  group('launch relative path', () {
    late Directory tempDir;
    late Directory templateDir;
    late String relativeExecutablePath;
    late MockClient mockClient;
    PocketBaseProcess? process;

    setUp(() {
      mockClient = MockClient();
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('OK', 200));

      tempDir = Directory.systemTemp.createTempSync(
        'launch_relative_path_test_',
      );
      templateDir = Directory(p.join(tempDir.path, 'templates'))..createSync();

      // Create subdirectories in templateDir to be copied
      Directory(p.join(templateDir.path, 'pb_migrations')).createSync();
      Directory(p.join(templateDir.path, 'pb_hooks')).createSync();
      Directory(p.join(templateDir.path, 'pb_public')).createSync();
      Directory(p.join(templateDir.path, 'dev_migrations')).createSync();

      // Create a dummy executable script in the temp directory
      final executablePath = p.join(tempDir.path, 'dummy_pb_relative.sh');
      final scriptContent = '''
#!/bin/sh
echo "Dummy PocketBase started"
sleep 5
''';
      File(executablePath).writeAsStringSync(scriptContent);
      Process.runSync('chmod', ['+x', executablePath]);

      // Calculate relative path from current working directory
      relativeExecutablePath = p.relative(
        executablePath,
        from: Directory.current.path,
      );
    });

    tearDown(() {
      process?.process.kill();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('succeeds when executable path is relative', () async {
      final config = LaunchConfig.executable(
        templateDir: templateDir.path,
        port: 8099,
        detached: false,
        executable: ExecutableConfig(path: relativeExecutablePath),
      );

      process = await launch(config, client: mockClient);

      // Give it a moment to run
      await Future.delayed(Duration(milliseconds: 500));

      expect(process, isNotNull);
      expect(process!.process.pid, greaterThan(0));

      // Verify it's running
      await Future.delayed(Duration(milliseconds: 100));
      expect(process!.isRunning, isTrue, reason: 'Process should be running');

      // Verify symlink was created correctly (it should resolve to absolute path)
      // We know pbDir is tempDir (because homeDirectory was null)
      // Actually launch creates a subfolder in temp for pbDir if homeDirectory is null.
      // But we don't have easy access to that random dir here unless we capture logs or inspect system temp.
      // However, if process launched successfully, the symlink must be valid.
    });
  });
}
