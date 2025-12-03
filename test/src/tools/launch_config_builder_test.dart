import 'dart:io';

import 'package:pb_obtain/src/tools/config_builder.dart';
import 'package:pb_obtain/src/tools/launch_config_builder.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('LaunchConfigBuilder', () {
    late Directory tempDir;
    late LaunchConfigBuilder builder;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'launch_config_builder_test',
      );
      builder = LaunchConfigBuilder();
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

    // This test expects failure because no config is provided and defaults might clash or be insufficient?
    // Actually, ConfigBuilder throws ConfigHelpException if config is null.
    // But LaunchConfig.merge should return a config if defaults work.
    // If ArgPicker crashes, we'll see.
    test('buildConfig with defaults', () {
      final config = builder.buildConfig([]);
      // If it succeeds, it should have defaults.
      expect(config.port, 8696);
      expect(config.executable, isNotNull);
      expect(config.obtain, isNull);
    });

    test('buildConfig throws ConfigUserException on invalid args', () {
      expect(
        () => builder.buildConfig(['--unknown-arg']),
        throwsA(isA<ConfigUserException>()),
      );
    });

    test('buildConfig parses YAML correctly', () {
      final yamlPath = p.join(tempDir.path, 'config.yaml');
      File(yamlPath).writeAsStringSync('''
templateDir: "tpl"
port: 8080
detached: false
executable:
  path: "/bin/pb"
''');

      final config = builder.buildConfig(['--yaml', yamlPath]);
      expect(config.templateDir, 'tpl');
      expect(config.port, 8080);
      expect(config.executable?.path, '/bin/pb');
      expect(config.obtain, isNull);
    });

    test('buildConfig merges CLI args over YAML', () {
      final yamlPath = p.join(tempDir.path, 'config.yaml');
      File(yamlPath).writeAsStringSync('''
templateDir: "tpl"
port: 8080
detached: false
executable:
  path: "/bin/pb"
''');

      final config = builder.buildConfig([
        '--yaml',
        yamlPath,
        '--port',
        '9090',
      ]);
      expect(config.port, 9090);
      expect(config.templateDir, 'tpl');
    });

    test('buildConfig throws ConfigUserException on invalid YAML content', () {
      final yamlPath = p.join(tempDir.path, 'bad_config.yaml');
      File(yamlPath).writeAsStringSync('''
templateDir: "tpl"
port: "not-a-number"
''');
      expect(
        () => builder.buildConfig(['--yaml', yamlPath]),
        throwsA(isA<ConfigUserException>()),
      );
    });

    test('buildConfig throws ConfigUserException on malformed YAML syntax', () {
      final yamlPath = p.join(tempDir.path, 'bad_syntax.yaml');
      File(yamlPath).writeAsStringSync('''
: : :
''');
      expect(
        () => builder.buildConfig(['--yaml', yamlPath]),
        throwsA(isA<ConfigUserException>()),
      );
    });
  });
}
