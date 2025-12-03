import 'package:args/args.dart';

class ArgPicker<C> {
  final C? base;
  final ArgResults results;
  bool _pickedAny = false;

  bool get pickedAny => _pickedAny;

  ArgPicker(this.base, this.results);

  T? pickArg<T>(String name, T Function(String) converter) {
    if (base == null || results.wasParsed(name)) {
      _pickedAny = true;
      return converter(results[name] as String);
    }
    return null;
  }

  String? pickString(String name) {
    return pickArg(name, (parsed) => parsed);
  }

  bool? pickFlag(String flagName) {
    if (base == null || results.wasParsed(flagName)) {
      _pickedAny = true;
      return results[flagName] as bool;
    }
    return null;
  }
}
