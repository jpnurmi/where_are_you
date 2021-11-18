import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'geo_data.dart';
import 'geo_location.dart';

const _kBaseUrl = 'http://geoname-lookup.ubuntu.com/';

class GeoService {
  GeoService(this._geodata, {@visibleForTesting Dio? dio})
      : _dio = dio ?? Dio();

  final Dio _dio;
  CancelToken? _token;
  final Geodata _geodata;

  Future<Iterable<GeoLocation>> search(
    String name, {
    String? release,
    String? lang,
    bool? online,
  }) {
    return Future.wait([
      _searchOffline(name),
      if (online == true) _searchOnline(name, release, lang),
    ]).then((value) => Set.of(value.expand((e) => e)));
  }

  Future<Iterable<GeoLocation>> _searchOffline(String name) {
    return _geodata.search(name);
  }

  Future<Iterable<GeoLocation>> _searchOnline(
    String name,
    String? release,
    String? lang,
  ) {
    return _cancelQuery()
        .then((_) => _sendQuery(name, release, lang))
        .then(_onQueryResponse)
        .catchError(_onQueryError);
  }

  Future<void> _cancelQuery() async => _token?.cancel();

  Future<Response> _sendQuery(String query, String? release, String? lang) {
    return _dio.get(
      _kBaseUrl,
      queryParameters: <String, String>{
        'query': query,
        if (release != null) 'release': release,
        if (lang != null) 'lang': lang,
      },
      cancelToken: _token = CancelToken(),
      options: Options(responseType: ResponseType.plain),
    );
  }

  Future<Iterable<GeoLocation>> _onQueryError(Object? error) async {
    if (error is DioError && CancelToken.isCancel(error)) {
      print('CANCEL: ${error.message}');
    } else {
      print('TODO: $error');
    }
    return <GeoLocation>[];
  }

  Future<Iterable<GeoLocation>> _onQueryResponse(Response response) async {
    final items = json.decode(response.data.toString()) as Iterable;
    return items.map((json) => GeoLocation.fromJson(json));
  }
}
