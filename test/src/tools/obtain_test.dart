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
import 'package:pb_obtain/src/tools/system_info.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
  MockSpec<OsInfo>(),
  MockSpec<ArchitectureInfo>(),
])
import 'obtain_test.mocks.dart';

void main() {
  group('obtain', () {
    late MockClient mockClient;
    late MockOsInfo mockOsInfo;
    late MockArchitectureInfo mockArchInfo;
    late Directory tempDir;

    setUp(() {
      mockClient = MockClient();
      mockOsInfo = MockOsInfo();
      mockArchInfo = MockArchitectureInfo();
      tempDir = Directory.systemTemp.createTempSync('pb_obtain_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final testCases = [
      {
        'osName': 'linux',
        'arch': 'amd64',
        'isWindows': false,
        'exeName': 'pocketbase',
      },
      {
        'osName': 'darwin',
        'arch': 'arm64',
        'isWindows': false,
        'exeName': 'pocketbase',
      },
      {
        'osName': 'windows',
        'arch': 'amd64',
        'isWindows': true,
        'exeName': 'pocketbase.exe',
      },
    ];

    for (final testCase in testCases) {
      final osName = testCase['osName'] as String;
      final arch = testCase['arch'] as String;
      final isWindows = testCase['isWindows'] as bool;
      final exeName = testCase['exeName'] as String;

      test(
        'downloads and extracts pocketbase successfully ($osName/$arch)',
        () async {
          final config = ObtainConfig(
            githubTag: 'v0.31.0',
            downloadDir: tempDir.path,
          );

          when(mockOsInfo.osName).thenReturn(osName);
          when(mockOsInfo.isWindows).thenReturn(isWindows);
          when(mockArchInfo.getCpuArchitecture()).thenAnswer((_) async => arch);

          final targetName = 'pocketbase_0.31.0_${osName}_$arch.zip';

          // Create a mock zip file containing the executable
          final archive = Archive();
          final content = 'fake_pocketbase_binary_content';
          archive.addFile(
            ArchiveFile(exeName, content.length, content.codeUnits),
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
              {
                'name': targetName,
                'browser_download_url': binaryUrl.toString(),
              },
              {
                'name': 'checksums.txt',
                'browser_download_url': checksumUrl.toString(),
              },
            ],
          };

          when(mockClient.get(releaseUrl)).thenAnswer(
            (_) async => http.Response(jsonEncode(releaseJson), 200),
          );

          when(
            mockClient.readBytes(binaryUrl),
          ).thenAnswer((_) async => Uint8List.fromList(zipBytes));

          when(mockClient.read(checksumUrl)).thenAnswer(
            (_) async => '$zipDigest  $targetName\nothersha  otherfile.zip',
          );

          // Execute
          final resultPath = await obtain(
            config,
            httpClient: mockClient,
            osInfo: mockOsInfo,
            architectureInfo: mockArchInfo,
          );

          // Verify
          final expectedPath = p.join(tempDir.path, 'v0.31.0', exeName);
          expect(resultPath, expectedPath);
          expect(File(resultPath).existsSync(), isTrue);
          expect(File(resultPath).readAsStringSync(), content);

          if (!isWindows) {
            // Verify chmod was likely called (we can at least check if the file exists,
            // checking x bit relies on host OS which we know is Linux).
            if (Platform.isLinux || Platform.isMacOS) {
              final stat = File(resultPath).statSync();
              expect(stat.modeString().contains('x'), isTrue);
            }
          }
        },
      );
    }

    test('throws exception on checksum mismatch', () async {
      final config = ObtainConfig(
        githubTag: 'v0.31.0',
        downloadDir: tempDir.path,
      );

      // Use linux settings for this test
      when(mockOsInfo.osName).thenReturn('linux');
      when(mockOsInfo.isWindows).thenReturn(false);
      when(mockArchInfo.getCpuArchitecture()).thenAnswer((_) async => 'amd64');

      final targetName = 'pocketbase_0.31.0_linux_amd64.zip';
      final exeName = 'pocketbase';

      // Create a mock zip file
      final archive = Archive();
      archive.addFile(ArchiveFile(exeName, 0, []));
      final zipBytes = ZipEncoder().encode(archive);
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
        () => obtain(
          config,
          httpClient: mockClient,
          osInfo: mockOsInfo,
          architectureInfo: mockArchInfo,
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains('Checksum verification failed'),
          ),
        ),
      );
    });
  });
}
