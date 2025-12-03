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
    };
