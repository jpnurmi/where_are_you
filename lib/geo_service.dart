import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:geocoder_offline/geocoder_offline.dart';

const _kBaseUrl = 'http://geoname-lookup.ubuntu.com/';

class GeoLocation {
  GeoLocation({
    this.name,
    this.admin1,
    this.country,
    this.longitude,
    this.latitude,
  });

  final String? name;
  final String? admin1;
  final String? country;
  final double? longitude;
  final double? latitude;

  GeoLocation copyWith({
    String? name,
    String? admin1,
    String? country,
    double? longitude,
    double? latitude,
  }) {
    return GeoLocation(
      name: name ?? this.name,
      admin1: admin1 ?? this.admin1,
      country: country ?? this.country,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admin1': admin1,
      'country': country,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> map) {
    return GeoLocation(
      name: map['name'],
      admin1: map['admin1'],
      country: map['country'],
      longitude: double.tryParse(map['longitude']),
      latitude: double.tryParse(map['latitude']),
    );
  }

  @override
  String toString() =>
      'GeoLocation(name: $name, admin1: $admin1, country: $country, longitude: $longitude, latitude: $latitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        other.name == name &&
        other.admin1 == admin1 &&
        other.country == country &&
        other.longitude == longitude &&
        other.latitude == latitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      name.hashCode,
      admin1.hashCode,
      country.hashCode,
      longitude.hashCode,
      latitude.hashCode,
    );
  }
}

class GeoService {
  GeoService(
    this._geocode, {
    @visibleForTesting Dio? dio,
  }) : _dio = dio ?? Dio();

  final GeocodeData _geocode;
  final Dio _dio;
  CancelToken? _token;

  Future<void> init() async {}

  Future<Iterable<GeoLocation>> searchName(
    String name, {
    String? release,
    String? lang,
  }) async {
    print('search name: $name');
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
