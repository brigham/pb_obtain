// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaunchConfig _$LaunchConfigFromJson(Map<String, dynamic> json) =>
    LaunchConfig._(
      templateDir: json['templateDir'] as String,
      port: (json['port'] as num).toInt(),
      detached: json['detached'] as bool,
      executable: json['executable'] == null
          ? null
          : ExecutableConfig.fromJson(
              json['executable'] as Map<String, dynamic>,
            ),
      obtain: json['obtain'] == null
          ? null
          : ObtainConfig.fromJson(json['obtain'] as Map<String, dynamic>),
      homeDirectory: json['homeDirectory'] as String?,
    );

Map<String, dynamic> _$LaunchConfigToJson(LaunchConfig instance) =>
    <String, dynamic>{
      'templateDir': instance.templateDir,
      'executable': instance.executable,
      'obtain': instance.obtain,
      'homeDirectory': instance.homeDirectory,
      'port': instance.port,
      'detached': instance.detached,
    };
