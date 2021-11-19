import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:where_are_you/geo_data.dart';
import 'package:where_are_you/geo_exception.dart';
import 'package:where_are_you/geo_location.dart';
import 'package:where_are_you/geo_name.dart';

import 'geo_name_test.mocks.dart';
import 'test_geodata.dart';

@GenerateMocks([Dio])
void main() {
  final response = Response(
    data: '''
[
  {
    "name": "Copenhagen",
    "admin1": "Capital Region",
    "country": "Denmark",
    "latitude": "55.67594",
    "longitude": "12.56553",
    "timezone": "Europe/Copenhagen"
  }
]
''',
    statusCode: 200,
    requestOptions: RequestOptions(path: '/'),
  );

  final errorResponse = Response(
    data: null,
    statusCode: 500,
    requestOptions: RequestOptions(path: '/'),
  );

  test('search', () async {
    final geodata = Geodata(
      loadCities: () => kCities,
      loadAdmins: () => kAdmins,
      loadCountries: () => kCountries,
    );

    final dio = MockDio();
    when(dio.get(
      'http://lookup.geoname.org',
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: null,
    )).thenAnswer((_) async => response);

    final geoname = Geoname(
      url: 'http://lookup.geoname.org',
      geodata: geodata,
      dio: dio,
    );

    expect(
      await geoname.search('foo'),
      [
        GeoLocation(
          name: 'Copenhagen',
          admin: 'Capital Region',
          country: 'Denmark',
          country2: 'DK',
          latitude: 55.67594,
          longitude: 12.56553,
          timezone: 'Europe/Copenhagen',
        )
      ],
    );
    verify(dio.get(
      'http://lookup.geoname.org',
      queryParameters: <String, String>{'query': 'foo'},
      cancelToken: anyNamed('cancelToken'),
    ));
  });

  test('lang & release', () async {
    final geodata = Geodata(
      loadCities: () => kCities,
      loadAdmins: () => kAdmins,
      loadCountries: () => kCountries,
    );

    final dio = MockDio();
    when(dio.get(
      'http://lookup.geoname.org',
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: null,
    )).thenAnswer((_) async => response);

    final geoname = Geoname(
      url: 'http://lookup.geoname.org',
      geodata: geodata,
      release: 'bar',
      lang: 'baz',
      dio: dio,
    );

    await geoname.search('foo');
    verify(dio.get(
      'http://lookup.geoname.org',
      queryParameters: <String, String>{
        'query': 'foo',
        'release': 'bar',
        'lang': 'baz',
      },
      cancelToken: anyNamed('cancelToken'),
    ));
  });

  test('error', () async {
    final geodata = Geodata(
      loadCities: () => kCities,
      loadAdmins: () => kAdmins,
      loadCountries: () => kCountries,
    );

    final dio = MockDio();
    when(dio.get(
      'http://lookup.geoname.org',
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
      onReceiveProgress: null,
    )).thenAnswer((_) async => errorResponse);

    final geoname = Geoname(
      url: 'http://lookup.geoname.org',
      geodata: geodata,
      release: 'bar',
      lang: 'baz',
      dio: dio,
    );

    await expectLater(
      () async => await geoname.search('foo'),
      throwsA(isA<GeoException>()),
    );
  });
}
