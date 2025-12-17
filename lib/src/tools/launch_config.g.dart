// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaunchConfig _$LaunchConfigFromJson(Map json) =>
    $checkedCreate('LaunchConfig', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'templateDir',
          'executable',
          'obtain',
          'homeDirectory',
          'port',
          'detached',
          'stdout',
          'stderr',
          'devMode',
        ],
      );
      final val = LaunchConfig._(
        templateDir: $checkedConvert('templateDir', (v) => v as String),
        port: $checkedConvert('port', (v) => (v as num).toInt()),
        detached: $checkedConvert('detached', (v) => v as bool),
        executable: $checkedConvert(
          'executable',
          (v) => v == null ? null : ExecutableConfig.fromJson(v as Map),
        ),
        obtain: $checkedConvert(
          'obtain',
          (v) => v == null ? null : ObtainConfig.fromJson(v as Map),
        ),
        homeDirectory: $checkedConvert('homeDirectory', (v) => v as String?),
        stdout: $checkedConvert('stdout', (v) => v as String?),
        stderr: $checkedConvert('stderr', (v) => v as String?),
        devMode: $checkedConvert('devMode', (v) => v as bool? ?? false),
      );
      return val;
    });

Map<String, dynamic> _$LaunchConfigToJson(LaunchConfig instance) =>
    <String, dynamic>{
      'templateDir': instance.templateDir,
      'executable': instance.executable,
      'obtain': instance.obtain,
      'homeDirectory': instance.homeDirectory,
      'port': instance.port,
      'detached': instance.detached,
      'stdout': instance.stdout,
      'stderr': instance.stderr,
      'devMode': instance.devMode,
    };
