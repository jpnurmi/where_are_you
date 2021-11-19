import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:where_are_you/geo_exception.dart';
import 'package:where_are_you/geo_location.dart';
import 'package:where_are_you/geo_ip.dart';

import 'geo_ip_test.mocks.dart';
import 'test_geodata.dart';

@GenerateMocks([Dio])
void main() {
  test('lookup', () async {
    final dio = MockDio();
    when(dio.get(
      'http://lookup.geoip.org',
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => xmlResponse);

    final geoip = GeoIP(
      url: 'http://lookup.geoip.org',
      geodata: geodata,
      dio: dio,
    );

    expect(
      await geoip.lookup(),
      GeoLocation(
        name: 'Copenhagen',
        admin: 'Capital Region',
        country: 'Denmark',
        country2: 'DK',
        latitude: 55.67594,
        longitude: 12.56553,
        timezone: 'Europe/Copenhagen',
      ),
    );
    verify(dio.get(
      'http://lookup.geoip.org',
      cancelToken: anyNamed('cancelToken'),
    ));
  });

  test('error', () async {
    final dio = MockDio();
    when(dio.get('http://lookup.geoip.org',
            cancelToken: anyNamed('cancelToken')))
        .thenAnswer((_) async => errorResponse);

    final geoip = GeoIP(
      url: 'http://lookup.geoip.org',
      geodata: geodata,
      dio: dio,
    );

    await expectLater(
      () async => await geoip.lookup(),
      throwsA(isA<GeoException>()),
    );
  });
}
