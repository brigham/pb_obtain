# pb_obtain

Download (and run) a specific PocketBase release for tests or whenever
it may come in handy.

## Experimental

This package is experimental and will have significant cleanup
around the YAML and command line flags.

I'm expecting to get to 1.0 quickly after those are sorted out.

## Getting Started

Choose a directory (`RELEASE_DIRECTORY`) where you will store the downloaded binaries.

Optional: create a directory (`POCKETBASE_CONFIG`) to store your 
migrations and hooks that will be used to start up PocketBase.

You can either create a YAML file for reusable config or just use
the command line flags.

```yaml
# PocketBase DTO Generator Configuration
version: RELEASE_VERSION
release-directory: RELEASE_DIRECTORY
config: POCKETBASE_CONFIG
port: PORT
```

Add this package as a dependency.

```shell
$ dart pub add dev:pb_obtain
```

Run `dart run pb_obtain:start_pocketbase`. You should run this command
when you update your migrations or when you upgrade this package.

## Programmatic Usage

You can use `pb_obtain` directly in your Dart code, which is especially useful
for integration tests.

### Downloading PocketBase

Use `obtain` to download and extract a specific PocketBase version.

```dart
import 'package:pb_obtain/pb_obtain.dart';

void main() async {
  final config = ObtainConfig(
    githubTag: 'v0.31.0',
    downloadDir: './pb_releases',
  );

  final executablePath = await obtain(config);
  print('PocketBase is at: $executablePath');
}
```

### Launching PocketBase for Tests

The `launch` function sets up a temporary directory with your migrations and
starts a PocketBase process. It waits for the server to be healthy before
returning.

```dart
import 'package:pb_obtain/pb_obtain.dart';
import 'package:test/test.dart';

void main() {
  group('Integration Tests', () {
    PocketBaseProcess? pb;

    setUp(() async {
      final config = LaunchConfig.obtain(
        templateDir: './pocketbase_template', // migrations, hooks, public
        port: 8090,
        obtain: ObtainConfig(
          githubTag: 'v0.31.0',
          downloadDir: './pb_releases',
        ),
      );

      pb = await launch(config);
    });

    tearDown(() async {
      await pb?.stop();
    });

    test('PocketBase is running', () async {
      expect(pb?.isRunning, isTrue);
      // Your test logic here...
    });
  });
}
```

The `PocketBaseProcess` object provides:
- `process`: The underlying `dart:io` `Process`.
- `isRunning`: Whether the process is still running.
- `stop()`: Shuts down the process gracefully and waits for it to exit.
