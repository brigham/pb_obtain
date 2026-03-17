import 'package:args/args.dart';

class ArgPicker<C> {
  final C? base;
  final ArgResults results;
  bool _pickedAny = false;

  bool get pickedAny => _pickedAny;

  ArgPicker(this.base, this.results);

  T? pickArg<T>(String name, T Function(String) converter) {
    if (base == null || results.wasParsed(name)) {
      final value = results[name];
      if (value != null) {
        _pickedAny = true;
        return converter(value as String);
      }
    }
    return null;
  }

  String? pickString(String name) {
    return pickArg(name, (parsed) => parsed);
  }

  Map<String, List<String>>? pickMultiStringMap(String name) {
    if (base == null || results.wasParsed(name)) {
      final value = results[name];
      if (value != null) {
        _pickedAny = true;
        final list = value as List<String>;
        final map = <String, List<String>>{};
        for (var item in list) {
          final parts = item.split(':');
          if (parts.length < 2) {
            throw ArgumentError.value(
              item,
              name,
              'must be in the format <dest>:<source>',
            );
          }
          final dest = parts[0];
          final source = parts
              .sublist(1)
              .join(':'); // Re-join in case of Windows paths like C:\
          map.putIfAbsent(dest, () => []).add(source);
        }
        return map;
      }
    }
    return null;
  }

  bool? pickFlag(String flagName) {
    if (base == null || results.wasParsed(flagName)) {
      _pickedAny = true;
      return results[flagName] as bool;
    }
    return null;
  }
}
