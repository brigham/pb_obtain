import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

enum PocketBaseProcessHealth {
  started,
  running,
  stopped;

  /// Returns `true` if [next] is a follow up state from [this].
  bool isReachable(PocketBaseProcessHealth next) {
    switch (this) {
      case .started:
        return true;
      case .running:
        return next != .started;
      case .stopped:
        return next == .stopped;
    }
  }
}

/// A [Process] wrapper that watches `exitCode` and allows for detecting it has
/// changed.
///
/// Note that process state changes will only be observable when the internal
/// promise gets a chance to execute its callback. Thus, callers should consider
/// inserting a noop await such as `await Future.delayed(Duration.zero)` if
/// the check is part of an otherwise synchronous code path.
class PocketBaseProcess {
  final Process _process;
  final String _httpHost;
  int? _exitCode;

  PocketBaseProcess(this._process, this._httpHost) {
    unawaited(_process.exitCode.then((v) => _exitCode = v));
  }

  /// The monitored [Process].
  Process get process => _process;

  /// Returns `true` if the process is believed to be running.
  bool get isRunning => _exitCode == null;

  /// Returns the exit code of the process, if it is known to have exited.
  int? get exitCode => _exitCode;

  Future<PocketBaseProcessHealth> getHealthy({http.Client? client}) async {
    if (_exitCode != null) {
      return .stopped;
    }
    try {
      var httpClient = client ?? http.Client();
      var response = await httpClient.get(
        Uri.parse('http://$_httpHost/api/health'),
      );
      return response.statusCode == 200 ? .running : .started;
    } catch (e) {
      return .started;
    }
  }

  /// Checks for [duration] until [getHealthy] returns [desiredHealth], waiting
  /// [period] between each check.
  ///
  /// Because the `getHealthy` call takes non-negligible time, there is almost
  /// no chance that `duration / period` checks will be made, as the `duration`
  /// enforcement is strict.
  Future<bool> waitFor(
    PocketBaseProcessHealth desiredHealth, {
    Duration duration = const Duration(seconds: 20),
    Duration period = const Duration(seconds: 1),
    http.Client? client,
  }) async {
    var httpClient = client ?? http.Client();
    var checkUntil = DateTime.now().add(duration);
    var timeLeft = duration;
    while (timeLeft.compareTo(Duration.zero) > 0) {
      try {
        var latestHealth = await getHealthy(
          client: httpClient,
        ).timeout(timeLeft);
        if (latestHealth == desiredHealth) {
          return true;
        }
        if (!latestHealth.isReachable(desiredHealth)) {
          return false;
        }
      } on TimeoutException {
        return false;
      }
      await Future<void>.delayed(period);
      timeLeft = checkUntil.difference(DateTime.now());
    }
    return false;
  }

  Future<bool> stop({
    Duration duration = const Duration(seconds: 20),
    Duration period = const Duration(seconds: 1),
    http.Client? client,
  }) async {
    if (_exitCode != null) {
      return true;
    }
    _process.kill();
    return waitFor(
      .stopped,
      duration: duration,
      period: period,
      client: client,
    );
  }
}
