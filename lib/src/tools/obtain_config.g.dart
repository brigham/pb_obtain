// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obtain_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObtainConfig _$ObtainConfigFromJson(Map json) =>
    $checkedCreate('ObtainConfig', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['githubTag', 'downloadDir']);
      final val = ObtainConfig(
        githubTag: $checkedConvert('githubTag', (v) => v as String),
        downloadDir: $checkedConvert('downloadDir', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ObtainConfigToJson(ObtainConfig instance) =>
    <String, dynamic>{
      'githubTag': instance.githubTag,
      'downloadDir': instance.downloadDir,
    };
