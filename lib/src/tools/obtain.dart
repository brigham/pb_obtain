import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'obtain_config.dart';
import 'system_info.dart';

void _log(String message) {
  stderr.writeln(message);
}

Future<String> obtain(
  ObtainConfig config, {
  http.Client? httpClient,
  OsInfo? osInfo,
  ArchitectureInfo? architectureInfo,
}) async {
  final client = httpClient ?? http.Client();
  final osInfoImpl = osInfo ?? OsInfo();
  final archInfoImpl = architectureInfo ?? ArchitectureInfo();

  try {
    final downloadDir = Directory(p.join(config.downloadDir, config.githubTag));
    if (!downloadDir.existsSync()) {
      downloadDir.createSync(recursive: true);
    }

    final executableName = osInfoImpl.isWindows
        ? 'pocketbase.exe'
        : 'pocketbase';
    final executablePath = p.join(downloadDir.path, executableName);

    if (File(executablePath).existsSync()) {
      _log('PocketBase executable already exists at $executablePath');
      return executablePath;
    }

    _log('Obtaining PocketBase ${config.githubTag}...');

    // 1. Identify Platform
    final os = osInfoImpl.osName;
    final arch = await archInfoImpl.getCpuArchitecture();

    // 2. Fetch Release Info
    final releaseUrl =
        'https://api.github.com/repos/pocketbase/pocketbase/releases/tags/${config.githubTag}';
    _log('Fetching release info from $releaseUrl');
    final response = await client.get(Uri.parse(releaseUrl));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch release info: ${response.statusCode} ${response.body}',
      );
    }

    final releaseJson = jsonDecode(response.body);
    final assets = releaseJson['assets'] as List;

    // 3. Find Assets
    final versionStr = config.githubTag.startsWith('v')
        ? config.githubTag.substring(1)
        : config.githubTag;
    final targetName = 'pocketbase_${versionStr}_${os}_$arch.zip';

    _log('Looking for asset: $targetName');

    Map<String, dynamic>? binaryAsset;
    Map<String, dynamic>? checksumAsset;

    for (var asset in assets) {
      if (asset['name'] == targetName) {
        binaryAsset = asset;
      }
      if (asset['name'] == 'checksums.txt') {
        checksumAsset = asset;
      }
    }

    if (binaryAsset == null) {
      throw Exception(
        'Could not find asset $targetName in release ${config.githubTag}',
      );
    }

    if (checksumAsset == null) {
      _log('Warning: checksums.txt not found. Verification will be skipped.');
    }

    // 4. Download
    final zipPath = p.join(downloadDir.path, targetName);
    _log('Downloading $targetName to $zipPath...');
    final zipBytes = await client.readBytes(
      Uri.parse(binaryAsset['browser_download_url']),
    );
    File(zipPath).writeAsBytesSync(zipBytes);

    // 5. Verify
    if (checksumAsset != null) {
      _log('Verifying checksum...');
      final checksumsContent = await client.read(
        Uri.parse(checksumAsset['browser_download_url']),
      );
      // checksums.txt format: "sha256_hash  filename"
      final lines = checksumsContent.split('\n');
      String? expectedHash;
      for (var line in lines) {
        if (line.trim().endsWith(targetName)) {
          expectedHash = line.trim().split(RegExp(r'\s+')).first;
          break;
        }
      }

      if (expectedHash == null) {
        _log(
          'Warning: Could not find checksum for $targetName in checksums.txt',
        );
      } else {
        final digest = sha256.convert(zipBytes);
        if (digest.toString() != expectedHash) {
          throw Exception(
            'Checksum verification failed! Expected $expectedHash, got $digest',
          );
        }
        _log('Checksum verified.');
      }
    }

    // 6. Unzip
    _log('Unzipping...');
    final archive = ZipDecoder().decodeBytes(zipBytes);
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        if (filename == 'pocketbase' || filename == 'pocketbase.exe') {
          File(executablePath)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);

          if (!osInfoImpl.isWindows) {
            await Process.run('chmod', ['+x', executablePath]);
          }
        }
      }
    }

    // Cleanup zip
    File(zipPath).deleteSync();

    _log('PocketBase obtained successfully at $executablePath');
    return executablePath;
  } finally {
    if (httpClient == null) {
      client.close();
    }
  }
}
