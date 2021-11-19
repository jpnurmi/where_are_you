import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'geo_data.dart';
import 'geo_location.dart';

class GeoIP {
  GeoIP({
    required this.url,
    required Geodata geodata,
    @visibleForTesting Dio? dio,
  })  : _dio = dio ?? Dio(),
        _geodata = geodata;

  final String url;

  final Dio _dio;
  final Geodata _geodata;

  Future<GeoLocation?> lookup() async {
    final options = Options(responseType: ResponseType.plain);
    final response = await _dio.get(url, options: options);
    return _geodata.fromXml(response.data.toString());
  }
}
