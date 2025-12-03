// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'executable_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExecutableConfig _$ExecutableConfigFromJson(Map json) =>
    $checkedCreate('ExecutableConfig', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['path']);
      final val = ExecutableConfig(
        path: $checkedConvert('path', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ExecutableConfigToJson(ExecutableConfig instance) =>
    <String, dynamic>{'path': instance.path};
