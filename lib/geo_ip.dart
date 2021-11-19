import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'geo_data.dart';
import 'geo_exception.dart';
import 'geo_location.dart';

final _options = BaseOptions(
  connectTimeout: 1000,
  receiveTimeout: 1000,
  responseType: ResponseType.plain,
);

class GeoIP {
  GeoIP({
    required this.url,
    required Geodata geodata,
    @visibleForTesting Dio? dio,
  })  : _dio = dio ?? Dio(_options),
        _geodata = geodata;

  final String url;

  final Dio _dio;
  CancelToken? _token;
  final Geodata _geodata;

  Future<GeoLocation?> lookup() async {
    return _cancel()
        .then((_) => _send())
        .then(_onResponse)
        .catchError(_onError);
  }

  Future<void> _cancel() async => _token?.cancel();

  Future<Response> _send() {
    return _dio.get(url, cancelToken: _token = CancelToken());
  }

  Future<GeoLocation?> _onResponse(Response response) async {
    if (response.statusCode != 200) {
      throw GeoException(response.statusMessage ?? 'Unknown error');
    }
    return _geodata.fromXml(response.data.toString());
  }

  Future<GeoLocation?> _onError(Object? error) async {
    if (error is DioError) {
      if (!CancelToken.isCancel(error)) throw GeoException(error.message);
    } else if (error != null) {
      throw error;
    }
    return null;
  }
}
