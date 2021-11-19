import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'geo_data.dart';
import 'geo_location.dart';
import 'geo_source.dart';

final _options = BaseOptions(
  connectTimeout: 1000,
  receiveTimeout: 1000,
  responseType: ResponseType.plain,
);

class Geoname implements GeoSource {
  Geoname({
    required this.url,
    required Geodata geodata,
    String? release,
    String? lang,
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
        .then((_) => _sendQuery(name, release, lang))
        .then(_onQueryResponse)
        .catchError(_onQueryError);
  }

  Future<void> _cancelQuery() async => _token?.cancel();

  Future<Response> _sendQuery(String query, String? release, String? lang) {
    return _dio.get(
      url,
      queryParameters: <String, String>{
        'query': query,
        if (release != null) 'release': release,
        if (lang != null) 'lang': lang,
      },
      cancelToken: _token = CancelToken(),
    );
  }

  Future<Iterable<GeoLocation>> _onQueryResponse(Response response) async {
    final items = json.decode(response.data.toString()) as Iterable;
    return Future.wait(items.map((json) => _geodata.fromJson(json)));
  }

  Future<Iterable<GeoLocation>> _onQueryError(Object? error) async {
    if (error is DioError && CancelToken.isCancel(error)) {
      print('CANCEL: ${error.message}');
    } else {
      print('TODO: $error');
    }
    return const <GeoLocation>[];
  }
}
