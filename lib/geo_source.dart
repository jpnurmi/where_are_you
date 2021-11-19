import 'geo_location.dart';

abstract class GeoSource {
  Future<Iterable<GeoLocation>> search(String name);
}
