import 'dart:async';
import 'dart:convert';

import 'geo_location.dart';

class Geodata {
  Geodata({
    required FutureOr<String> Function() loadCities,
    required FutureOr<String> Function() loadAdmins,
    required FutureOr<String> Function() loadCountries,
  })  : _loadCities = loadCities,
        _loadAdmins = loadAdmins,
        _loadCountries = loadCountries;

  final FutureOr<String> Function() _loadCities;
  final FutureOr<String> Function() _loadAdmins;
  final FutureOr<String> Function() _loadCountries;

  var _initialized = false;
  final _cities = <String, List<GeoLocation>>{};
  final _admins = <String, List<GeoLocation>>{};
  final _countries = <String, List<GeoLocation>>{};
  late final Map<String, String> _countries2;

  Future<String?> country2(String country) async {
    await _ensureInitialized();
    return _countries2[country];
  }

  Future<Iterable<GeoLocation>> search(String name) async {
    if (name.isEmpty) return [];
    await _ensureInitialized();
    return <GeoLocation>{
      ..._cities.find(name, _cityWhere),
      ..._admins.find(name, _adminWhere),
      ..._countries.find(name, _countryWhere),
    };
  }

  static bool _cityWhere(String name, GeoLocation city) {
    return city.name?.toLowerCase().startsWith(name) == true;
  }

  static bool _adminWhere(String name, GeoLocation city) {
    return _cityWhere(name, city) ||
        city.admin?.toLowerCase().startsWith(name) == true;
  }

  static bool _countryWhere(String name, GeoLocation city) {
    return _cityWhere(name, city) ||
        city.country?.toLowerCase().startsWith(name) == true;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    final adminCodes = _parseCodes(await _loadAdmins(), code: 0, name: 1);
    final countryCodes = _parseCodes(await _loadCountries(), code: 0, name: 4);
    for (final line in _splitGeodata(await _loadCities())) {
      final city = GeoLocation(
        name: line[1],
        admin: adminCodes['${line[8]}.${line[9]}'],
        country: countryCodes[line[8]],
        country2: line[8],
        latitude: double.tryParse(line[4]),
        longitude: double.tryParse(line[5]),
      );
      _cities.insert(city.name, city);
      _admins.insert(city.admin, city);
      _countries.insert(city.country, city);
    }
    _countries2 = countryCodes.reverse();
  }
}

extension _MapList<T> on Map<String, List<T>> {
  List<T> find(String key, bool Function(String, T) f) {
    if (key.isEmpty) return [];
    final l = key.toLowerCase();
    final m = <T>[];
    for (final v in this[l[0]] ?? []) {
      if (f(l, v)) m.add(v);
    }
    return m;
  }

  void insert(String? key, T value) {
    if (key?.isNotEmpty == true) {
      final k = key![0].toLowerCase();
      this[k] ??= <T>[];
      this[k]!.add(value);
    }
  }
}

extension _StringMap on Map<String, String> {
  Map<String, String> reverse<T>() => Map.fromIterables(values, keys);
}

Map<String, String> _parseCodes(
  String data, {
  required int code,
  required int name,
}) {
  final codes = <String, String>{};
  for (final line in _splitGeodata(data)) {
    if (line.isEmpty) continue;
    codes[line[code]] = line[name];
  }
  return codes;
}

Iterable<List<String>> _splitGeodata(String data) {
  return LineSplitter.split(data).map((line) => line
      .split('#') // ignore comments
      .first
      .split('\t') // tab-separated data
      .where((f) => f.trim().isNotEmpty)
      .toList());
}
