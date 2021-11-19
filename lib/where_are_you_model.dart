import 'package:flutter/foundation.dart';

import 'geo_location.dart';
import 'geo_service.dart';

class WhereAreYouModel extends ChangeNotifier {
  WhereAreYouModel(GeoService service) : _service = service;

  final GeoService _service;

  String? lang;
  String? release;

  String? _lastName;
  GeoLocation? _selectedLocation;
  var _locations = const Iterable<GeoLocation>.empty();

  var _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    _service.init().then((location) {
      _initialized = true;
      _selectedLocation = location;
      notifyListeners();
    });
  }

  GeoLocation? get selectedLocation => _selectedLocation;

  void selectLocation(GeoLocation? location) {
    if (_selectedLocation == location) return;
    _selectedLocation = location;
    _lastName = null;
    notifyListeners();
  }

  Iterable<GeoLocation> get locations => _locations;
  Iterable<GeoLocation> _updateLocations(Iterable<GeoLocation> locations) {
    _locations = locations;
    notifyListeners();
    return _locations;
  }

  Future<Iterable<GeoLocation>> searchLocation(String name) async {
    if (name.isEmpty) return [];
    if (_lastName == name) return _locations;
    _lastName = name;
    _selectedLocation = null;
    return _service.search(name).then(_updateLocations);
  }
}
