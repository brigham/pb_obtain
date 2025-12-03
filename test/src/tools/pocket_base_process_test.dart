import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:pb_obtain/src/tools/pocket_base_process.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'pocket_base_process_test.mocks.dart';

void main() {
  late Directory tempDir;
  late String dummyExecutablePath;

  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();

    tempDir = Directory.systemTemp.createTempSync('smart_process_test_');

    // Create dummy executable script
    dummyExecutablePath = p.join(tempDir.path, 'dummy_pb.sh');
    final scriptContent = '''
#!/bin/sh
echo "Dummy PocketBase started"
echo "Args: \$@"
# Keep running for a bit to allow detection
sleep 0.25
''';
    File(dummyExecutablePath).writeAsStringSync(scriptContent);
    Process.runSync('chmod', ['+x', dummyExecutablePath]);
  });

  test('isRunning', () async {
    var process = PocketBaseProcess(
      await Process.start(dummyExecutablePath, []),
      '',
    );

    expect(process.isRunning, isTrue);
    await process.process.exitCode;
    expect(process.isRunning, isFalse);
  });

  test('exitCode', () async {
    var process = PocketBaseProcess(
      await Process.start(dummyExecutablePath, []),
      '',
    );

    expect(process.exitCode, isNull);
    await process.process.exitCode;
    expect(process.exitCode, 0);
  });

  test('getHealthy', () async {
    var process = PocketBaseProcess(
      await Process.start(dummyExecutablePath, []),
      '127.0.0.1:9000',
    );

    expect(
      await process.getHealthy(client: mockClient),
      PocketBaseProcessHealth.started,
    );
    when(
      mockClient.get(Uri.parse('http://127.0.0.1:9000/api/health')),
    ).thenAnswer((_) async => http.Response('OK', 200));
    expect(
      await process.getHealthy(client: mockClient),
      PocketBaseProcessHealth.running,
    );
    await process.process.exitCode;
    expect(
      await process.getHealthy(client: mockClient),
      PocketBaseProcessHealth.stopped,
    );
  });

  test('waitFor', () async {
    var process = PocketBaseProcess(
      await Process.start(dummyExecutablePath, []),
      '127.0.0.1:9000',
    );

    expect(await process.waitFor(.started, client: mockClient), isTrue);
    when(
      mockClient.get(Uri.parse('http://127.0.0.1:9000/api/health')),
    ).thenAnswer((_) async => http.Response('Not Ready', 500));
    expect(
      await process.waitFor(
        .running,
        duration: Duration(milliseconds: 20),
        period: Duration(milliseconds: 5),
        client: mockClient,
      ),
      isFalse,
    );
    expect(process.exitCode, isNull);
    when(
      mockClient.get(Uri.parse('http://127.0.0.1:9000/api/health')),
    ).thenAnswer((_) async => http.Response('OK', 200));
    expect(await process.waitFor(.running, client: mockClient), isTrue);
    await process.process.exitCode;
    expect(await process.waitFor(.stopped, client: mockClient), isTrue);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });
}
