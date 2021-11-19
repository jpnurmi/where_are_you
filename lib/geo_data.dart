import 'dart:async';
import 'dart:convert';

import 'package:xml/xml.dart';

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

  Future<GeoLocation> fromJson(Map<String, dynamic> json) async {
    await _ensureInitialized();
    return GeoLocation(
      name: json.getStringOrNull('name'),
      admin: json.getStringOrNull('admin1'),
      country: json.getStringOrNull('country'),
      country2: json.getStringOrNull('country2', _countries2[json['country']]),
      latitude: json.getDoubleOrNull('latitude'),
      longitude: json.getDoubleOrNull('longitude'),
      timezone: json.getStringOrNull('timezone'),
    );
  }

  Future<GeoLocation?> fromXml(String xml) async {
    await _ensureInitialized();
    try {
      final element = XmlDocument.parse(xml).rootElement;
      if (element.getTextOrNull('Status') != 'OK') return null;
      return GeoLocation(
        name: element.getTextOrNull('City'),
        admin: element.getTextOrNull('RegionName'),
        country: element.getTextOrNull('CountryName'),
        country2: element.getTextOrNull('CountryCode'),
        latitude: element.getDoubleOrNull('Latitude'),
        longitude: element.getDoubleOrNull('Longitude'),
        timezone: element.getTextOrNull('TimeZone'),
      );
    } on XmlException {
      return null;
    }
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
        _adminWhere(name, city) ||
        city.country?.toLowerCase().startsWith(name) == true;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    final adminCodes = _parse(await _loadAdmins(), code: 0, name: 1);
    final countryCodes = _parse(await _loadCountries(), code: 0, name: 4);
    for (final line in _tokenize(await _loadCities())) {
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

extension _JsonMap on Map<String, dynamic> {
  String? getStringOrNull(String key, [String? fallback]) {
    final value = this[key];
    return value is String ? value : fallback;
  }

  double? getDoubleOrNull(String key) {
    final value = this[key];
    return value is double
        ? value
        : value is String
            ? double.tryParse(value)
            : null;
  }
}

extension _MapList<T> on Map<String, List<T>> {
  List<T> find(String key, bool Function(String, T) f) {
    final res = <T>[];
    final keys = key
        .toLowerCase()
        .split(' ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
    final values = keys.expand<T>((word) => this[word[0]] ?? []);
    for (final value in values) {
      if (keys.every((key) => f(key, value))) res.add(value);
    }
    return res;
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

extension _GetXmlText on XmlElement? {
  String? getTextOrNull(String name) => this?.getElement(name)?.text;
  double? getDoubleOrNull(String name) =>
      double.tryParse(getTextOrNull(name) ?? '');
}

Map<String, String> _parse(
  String data, {
  required int code,
  required int name,
}) {
  final codes = <String, String>{};
  for (final line in _tokenize(data)) {
    if (line.isEmpty) continue;
    codes[line[code]] = line[name];
  }
  return codes;
}

Iterable<List<String>> _tokenize(String data) {
  return LineSplitter.split(data).map((line) => line
      .split('#') // ignore comments
      .first
      .split('\t') // tab-separated data
      .where((f) => f.trim().isNotEmpty)
      .toList());
}
