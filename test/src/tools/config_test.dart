import 'dart:convert';

import 'package:pb_obtain/src/tools/executable_config.dart';
import 'package:pb_obtain/src/tools/launch_config.dart';
import 'package:pb_obtain/src/tools/obtain_config.dart';
import 'package:test/test.dart';

void main() {
  group('ObtainConfig', () {
    test('validate succeeds with valid data', () {
      var _ = ObtainConfig(githubTag: 'v0.0.0', downloadDir: 'tmp');
    });

    test('validate fails with empty githubTag', () {
      expect(() => ObtainConfig(githubTag: '', downloadDir: 'tmp'), throwsA(isA<ArgumentError>()));
    });

    test('validate fails with empty downloadDir', () {
      expect(() => ObtainConfig(githubTag: 'v0.0.0', downloadDir: ''), throwsA(isA<ArgumentError>()));
    });

    test('toJson/fromJson works', () {
      var config = ObtainConfig(githubTag: 'v0.0.0', downloadDir: 'tmp');
      final json = config.toJson();
      final config2 = ObtainConfig.fromJson(json);
      expect(config2.githubTag, config.githubTag);
      expect(config2.downloadDir, config.downloadDir);
    });
  });

  group('ExecutableConfig', () {
    test('validate succeeds with valid data', () {
      var _ = ExecutableConfig(path: 'path/to/exe');
    });

    test('validate fails with empty path', () {
      expect(() => ExecutableConfig(path: ''), throwsA(isA<ArgumentError>()));
    });

    test('toJson/fromJson works', () {
      var config = ExecutableConfig(path: 'path/to/exe');
      final json = config.toJson();
      final config2 = ExecutableConfig.fromJson(json);
      expect(config2.path, config.path);
    });
  });

  group('LaunchConfig', () {
    test('executable factory works', () {
      var config = LaunchConfig.executable(
        templateDir: 'tpl',
        port: 8090,
        detached: true,
        executable: ExecutableConfig(path: 'exe'),
      );
      expect(config.obtain, isNull);
      expect(config.executable, isNotNull);
      expect(config.detached, isTrue);
    });

    test('obtain factory works', () {
      var config = LaunchConfig.obtain(
        templateDir: 'tpl',
        port: 8090,
        detached: false,
        obtain: ObtainConfig(githubTag: 'v', downloadDir: 'd'),
      );
      expect(config.executable, isNull);
      expect(config.obtain, isNotNull);
      expect(config.detached, isFalse);
    });

    test('validate succeeds', () {
      var _ = LaunchConfig.executable(
        templateDir: 'tpl',
        port: 8090,
        detached: true,
        executable: ExecutableConfig(path: 'exe'),
      );
    });

    test('validate fails if templateDir empty', () {
      expect(() => LaunchConfig.executable(
        templateDir: '',
        port: 8090,
        detached: true,
        executable: ExecutableConfig(path: 'exe'),
      ), throwsA(isA<ArgumentError>()));
    });

    test('validate fails if port is 0', () {
      expect(() => LaunchConfig.executable(
        templateDir: 'tpl',
        port: 0,
        detached: true,
        executable: ExecutableConfig(path: 'exe'),
      ), throwsA(isA<ArgumentError>()));
    });

    test('toJson/fromJson works', () {
      var config = LaunchConfig.executable(
        templateDir: 'tpl',
        port: 8090,
        detached: true,
        executable: ExecutableConfig(path: 'exe'),
      );
      final json = config.toJson();
      final decoded = jsonDecode(jsonEncode(json));
      final config2 = LaunchConfig.fromJson(decoded);
      expect(config2.templateDir, config.templateDir);
      expect(config2.port, config.port);
    });
  });
}
