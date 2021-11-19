import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:where_are_you/geo_exception.dart';

import 'geo_data.dart';
import 'geo_location.dart';
import 'geo_source.dart';

final _options = BaseOptions(
  connectTimeout: 1000,
  receiveTimeout: 1000,
  responseType: ResponseType.json,
);

class Geoname implements GeoSource {
  Geoname({
    required this.url,
    required Geodata geodata,
    this.release,
    this.lang,
    @visibleForTesting Dio? dio,
  })  : _dio = dio ?? Dio(_options),
        _geodata = geodata;

  String url;
  String? release;
  String? lang;

  final Dio _dio;
  CancelToken? _token;
  final Geodata _geodata;

  @override
  Future<Iterable<GeoLocation>> search(String name) {
    return _cancelQuery()
        .then((_) => _sendQuery(name))
        .then(_onQueryResponse)
        .catchError(_onQueryError);
  }

  Future<void> _cancelQuery() async => _token?.cancel();

  Future<Response> _sendQuery(String query) {
    return _dio.get(
      url,
      queryParameters: <String, String>{
        'query': query,
        if (release != null) 'release': release!,
        if (lang != null) 'lang': lang!,
      },
      cancelToken: _token = CancelToken(),
    );
  }

  Future<Iterable<GeoLocation>> _onQueryResponse(Response response) async {
    if (response.statusCode != 200) {
      throw GeoException(response.statusMessage ?? 'Unknown error');
    }
    final items = json.decode(response.data.toString());
    if (items is! Iterable) {
      throw GeoException('Invalid response data');
    }
    return Future.wait(items.map((json) => _geodata.fromJson(json)));
  }

  Future<Iterable<GeoLocation>> _onQueryError(Object? error) async {
    if (error is DioError) {
      if (!CancelToken.isCancel(error)) throw GeoException(error.message);
    } else if (error != null) {
      throw error;
    }
    return const <GeoLocation>[];
  }
}
