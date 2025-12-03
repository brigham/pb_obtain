import 'dart:io';

import 'package:pb_obtain/src/tools/config_builder.dart';
import 'package:pb_obtain/src/tools/obtain_config_builder.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('ObtainConfigBuilder', () {
    late Directory tempDir;
    late ObtainConfigBuilder builder;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'obtain_config_builder_test',
      );
      builder = ObtainConfigBuilder();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('buildConfig throws ConfigHelpException on help', () {
      expect(
        () => builder.buildConfig(['--help']),
        throwsA(isA<ConfigHelpException>()),
      );
    });

    test('buildConfig throws ConfigUserException if missing required fields (cli)', () {
      // Expect validation error (ConfigUserException) or HelpException (if null)
      // If ArgPicker crashes, this test will fail (throws TypeError).
      try {
        builder.buildConfig([]);
        fail('Should have thrown');
      } catch (e) {
        if (e is ConfigUserException || e is ConfigHelpException) {
          // pass
        } else if (e is TypeError) {
          print('Caught TypeError: probably ArgPicker issue.');
          // If this happens, I should probably fix ArgPicker or ignore for now?
          // The prompt didn't ask to fix ArgPicker but I can't test properly if it crashes.
          // However, if the user only wants coverage, maybe crashing is "covered"?
          // But I'll assume valid usage for now.
          rethrow;
        } else {
          rethrow;
        }
      }
    });

    test('buildConfig succeeds with valid CLI args', () {
      final config = builder.buildConfig(['--tag', 'v0.1.0']);
      expect(config.githubTag, 'v0.1.0');
      expect(config.downloadDir, isNotEmpty);
    });

    test('buildConfig parses YAML correctly', () {
      final yamlPath = p.join(tempDir.path, 'config.yaml');
      File(yamlPath).writeAsStringSync('''
githubTag: "v0.2.0"
downloadDir: "/tmp/pb"
''');

      final config = builder.buildConfig(['--yaml', yamlPath]);
      expect(config.githubTag, 'v0.2.0');
      expect(config.downloadDir, '/tmp/pb');
    });

    test('buildConfig merges CLI args over YAML', () {
      final yamlPath = p.join(tempDir.path, 'config.yaml');
      File(yamlPath).writeAsStringSync('''
githubTag: "v0.2.0"
downloadDir: "/tmp/pb"
''');

      final config = builder.buildConfig([
        '--yaml',
        yamlPath,
        '--tag',
        'v0.3.0',
      ]);
      expect(config.githubTag, 'v0.3.0');
      expect(config.downloadDir, '/tmp/pb');
    });
  });
}
