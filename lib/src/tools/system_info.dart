import 'dart:io';

class OsInfo {
  String get osName {
    if (Platform.isLinux) {
      return 'linux';
    } else if (Platform.isMacOS) {
      return 'darwin';
    } else if (Platform.isWindows) {
      return 'windows';
    } else {
      throw UnsupportedError(
        'Unsupported operating system: ${Platform.operatingSystem}',
      );
    }
  }

  bool get isWindows => Platform.isWindows;
}

class ArchitectureInfo {
  Future<String> getCpuArchitecture() async {
    final version = Platform.version.toLowerCase();
    if (version.contains('arm64') || version.contains('aarch64')) {
      return 'arm64';
    } else if (version.contains('x64') || version.contains('x86_64')) {
      return 'amd64';
    } else {
      if (Platform.isMacOS &&
          (await Process.run('uname', ['-m'])).stdout.toString().trim() ==
              'arm64') {
        return 'arm64';
      } else {
        return 'amd64'; // Defaulting to amd64 for now
      }
    }
  }
}
