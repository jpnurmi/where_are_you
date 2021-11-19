import 'package:where_are_you/geo_ip.dart';

import 'geo_location.dart';
import 'geo_source.dart';

class GeoService {
  GeoService(GeoIP geoip) : _geoip = geoip;

  final GeoIP _geoip;
  final _geosources = <GeoSource>[];

  Future<GeoLocation?> init() => _geoip.lookup();

  void addSource(GeoSource source) => _geosources.add(source);
  void removeSource(GeoSource source) => _geosources.remove(source);

  Future<Iterable<GeoLocation>> search(String name) {
    return Future.wait([
      for (final geosource in _geosources) geosource.search(name),
    ]).then((value) => Set.of(value.expand((e) => e)));
  }
}
