import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:where_are_you/geo_exception.dart';
import 'package:where_are_you/geo_ip.dart';

import 'geo_ip_test.mocks.dart';
import 'test_geodata.dart';

const kTestUrl = 'http://lookup.geoip.org';

@GenerateMocks([Dio])
void main() {
  test('lookup', () async {
    final dio = MockDio();
    when(dio.get(
      kTestUrl,
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => xmlResponse(copenhagen));

    final geoip = GeoIP(url: kTestUrl, geodata: geodata, dio: dio);

    expect(await geoip.lookup(), copenhagen);
    verify(dio.get(kTestUrl, cancelToken: anyNamed('cancelToken')));
  });

  test('error', () async {
    final dio = MockDio();
    when(dio.get(kTestUrl, cancelToken: anyNamed('cancelToken')))
        .thenAnswer((_) async => errorResponse);

    final geoip = GeoIP(
      url: kTestUrl,
      geodata: geodata,
      dio: dio,
    );

    await expectLater(
      () async => await geoip.lookup(),
      throwsA(isA<GeoException>()),
    );
  });
}
