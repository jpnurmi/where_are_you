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

  GeoLocation? get selectedLocation => _selectedLocation;

  void selectLocation(GeoLocation? location) {
    if (_selectedLocation == location) return;
    print('select $location');
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
    if (_lastName == name) [];
    _lastName = name;
    _selectedLocation = null;
    return _service
        .search(name, lang: lang, release: release)
        .then(_updateLocations);
  }
}
