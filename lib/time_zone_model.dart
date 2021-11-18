import 'package:flutter/foundation.dart';

import 'geo_service.dart';

class TimeZoneModel extends ChangeNotifier {
  TimeZoneModel(GeoService service) : _service = service;

  final GeoService _service;

  String? lang;
  String? release;

  String? _lastName;
  GeoLocation? _selectedLocation;
  var _locations = const Iterable<GeoLocation>.empty();

  GeoLocation? get selectedLocation => _selectedLocation;

  void selectLocation(GeoLocation? location) {
    if (_selectedLocation == location) return;
    print('select $location');
    _selectedLocation = location;
    _lastName = null;
    notifyListeners();
  }

  Iterable<GeoLocation> get locations => _locations;
  void _updateLocations(Iterable<GeoLocation> locations) {
    _locations = locations;
    notifyListeners();
  }

  Future<void> searchLocation(String name) async {
    if (_lastName == name) return;
    _lastName = name;
    _selectedLocation = null;
    return _service
        .searchName(name, lang: lang, release: release)
        .then(_updateLocations);
  }
}
