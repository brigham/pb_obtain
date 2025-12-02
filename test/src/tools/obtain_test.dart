import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:pb_obtain/src/tools/obtain.dart';
import 'package:pb_obtain/src/tools/obtain_config.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'obtain_test.mocks.dart';

void main() {
  group('obtain', () {
    late MockClient mockClient;
    late Directory tempDir;

    setUp(() {
      mockClient = MockClient();
      tempDir = Directory.systemTemp.createTempSync('pb_obtain_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('downloads and extracts pocketbase successfully', () async {
      final config = ObtainConfig(
        githubTag: 'v0.31.0',
        downloadDir: tempDir.path,
      );

      // Replicate the logic to determine targetName
      String os;
      if (Platform.isLinux) {
        os = 'linux';
      } else if (Platform.isMacOS) {
        os = 'darwin';
      } else if (Platform.isWindows) {
        os = 'windows';
      } else {
        // Fallback for test environment if weird
        os = 'linux';
      }

      String arch;
      final version = Platform.version.toLowerCase();
      if (version.contains('arm64') || version.contains('aarch64')) {
        arch = 'arm64';
      } else if (version.contains('x64') || version.contains('x86_64')) {
        arch = 'amd64';
      } else {
        if (Platform.isMacOS &&
            (await Process.run('uname', ['-m'])).stdout.toString().trim() ==
                'arm64') {
          arch = 'arm64';
        } else {
          arch = 'amd64';
        }
      }

      final versionStr = '0.31.0';
      final targetName = 'pocketbase_${versionStr}_${os}_$arch.zip';
      final executableName = Platform.isWindows
          ? 'pocketbase.exe'
          : 'pocketbase';

      // Create a mock zip file containing the executable
      final archive = Archive();
      final content = 'fake_pocketbase_binary_content';
      archive.addFile(
        ArchiveFile(executableName, content.length, content.codeUnits),
      );
      final zipBytes = ZipEncoder().encode(archive);
      final zipDigest = sha256.convert(zipBytes);

      // Mock URLs
      final releaseUrl = Uri.parse(
        'https://api.github.com/repos/pocketbase/pocketbase/releases/tags/v0.31.0',
      );
      final binaryUrl = Uri.parse('https://example.com/$targetName');
      final checksumUrl = Uri.parse('https://example.com/checksums.txt');

      final releaseJson = {
        'assets': [
          {'name': targetName, 'browser_download_url': binaryUrl.toString()},
          {
            'name': 'checksums.txt',
            'browser_download_url': checksumUrl.toString(),
          },
        ],
      };

      // Set up mock expectations
      when(
        mockClient.get(releaseUrl),
      ).thenAnswer((_) async => http.Response(jsonEncode(releaseJson), 200));

      when(
        mockClient.readBytes(binaryUrl),
      ).thenAnswer((_) async => Uint8List.fromList(zipBytes));

      when(mockClient.read(checksumUrl)).thenAnswer(
        (_) async =>
            '$zipDigest  $targetName\n'
            'othersha  otherfile.zip',
      );

      // Execute
      final resultPath = await obtain(config, httpClient: mockClient);

      // Verify
      final expectedPath = p.join(tempDir.path, 'v0.31.0', executableName);
      expect(resultPath, expectedPath);
      expect(File(resultPath).existsSync(), isTrue);
      expect(File(resultPath).readAsStringSync(), content);

      // Verify executable permission on Linux/Mac
      if (!Platform.isWindows) {
        final stat = File(resultPath).statSync();
        // Check if executable bit is set for user (00100 -> 8? No)
        // rwx r-x r-x = 755.
        // We just want to ensure it's executable.
        // stat.modeString() returns like "rwxr-xr-x"
        expect(stat.modeString().contains('x'), isTrue);
      }
    });

    test('throws exception on checksum mismatch', () async {
      final config = ObtainConfig(
        githubTag: 'v0.31.0',
        downloadDir: tempDir.path,
      );

      // Replicate the logic to determine targetName (simplified copy-paste)
      String os;
      if (Platform.isLinux) {
        os = 'linux';
      } else if (Platform.isMacOS)
        os = 'darwin';
      else if (Platform.isWindows)
        os = 'windows';
      else
        os = 'linux';

      String arch;
      final version = Platform.version.toLowerCase();
      if (version.contains('arm64') || version.contains('aarch64')) {
        arch = 'arm64';
      } else if (version.contains('x64') || version.contains('x86_64')) {
        arch = 'amd64';
      } else {
        if (Platform.isMacOS &&
            (await Process.run('uname', ['-m'])).stdout.toString().trim() ==
                'arm64') {
          arch = 'arm64';
        } else {
          arch = 'amd64';
        }
      }

      final versionStr = '0.31.0';
      final targetName = 'pocketbase_${versionStr}_${os}_$arch.zip';
      final executableName = Platform.isWindows
          ? 'pocketbase.exe'
          : 'pocketbase';

      // Create a mock zip file
      final archive = Archive();
      archive.addFile(ArchiveFile(executableName, 0, []));
      final zipBytes = ZipEncoder().encode(archive);
      // Real digest
      // final zipDigest = sha256.convert(zipBytes);
      // Use fake digest for checksum file to cause mismatch
      final fakeDigest = 'badchecksum';

      final releaseUrl = Uri.parse(
        'https://api.github.com/repos/pocketbase/pocketbase/releases/tags/v0.31.0',
      );
      final binaryUrl = Uri.parse('https://example.com/$targetName');
      final checksumUrl = Uri.parse('https://example.com/checksums.txt');

      final releaseJson = {
        'assets': [
          {'name': targetName, 'browser_download_url': binaryUrl.toString()},
          {
            'name': 'checksums.txt',
            'browser_download_url': checksumUrl.toString(),
          },
        ],
      };

      when(
        mockClient.get(releaseUrl),
      ).thenAnswer((_) async => http.Response(jsonEncode(releaseJson), 200));

      when(
        mockClient.readBytes(binaryUrl),
      ).thenAnswer((_) async => Uint8List.fromList(zipBytes));

      when(
        mockClient.read(checksumUrl),
      ).thenAnswer((_) async => '$fakeDigest  $targetName');

      expect(
        () => obtain(config, httpClient: mockClient),
        throwsA(
          predicate(
            (e) => e.toString().contains('Checksum verification failed'),
          ),
        ),
      );
    });
  });
}
