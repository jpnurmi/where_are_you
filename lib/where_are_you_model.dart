import 'package:flutter/foundation.dart';

import 'geo_location.dart';
import 'geo_service.dart';
import 'network_service.dart';

class WhereAreYouModel extends ChangeNotifier {
  WhereAreYouModel({
    required GeoService geo,
    required NetworkService network,
  })  : _geo = geo,
        _network = network;

  final GeoService _geo;
  final NetworkService _network;

  String? lang;
  String? release;

  String? _lastName;
  GeoLocation? _selectedLocation;
  var _locations = const Iterable<GeoLocation>.empty();

  Future<void> init() => _network.connect().then((_) => notifyListeners());

  bool? _online;
  bool get isOnline => _online ?? _network.isOnline;
  void setOnline(bool? online) {
    if (_online == online) return;
    _online = online;
    notifyListeners();
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
    if (name.isEmpty || _lastName == name) return [];
    _lastName = name;
    _selectedLocation = null;
    return _geo
        .search(name, lang: lang, release: release, online: isOnline)
        .then(_updateLocations);
  }
}
