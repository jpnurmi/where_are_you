import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:where_are_you/geo_exception.dart';
import 'package:where_are_you/geo_name.dart';

import 'geo_name_test.mocks.dart';
import 'test_geodata.dart';

const kTestUrl = 'http://lookup.geoname.org';

@GenerateMocks([Dio])
void main() {
  test('search', () async {
    final dio = MockDio();
    when(dio.get(
      kTestUrl,
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => jsonResponse(copenhagen));

    final geoname = Geoname(url: kTestUrl, geodata: geodata, dio: dio);

    expect(await geoname.search('foo'), [copenhagen]);
    verify(dio.get(
      kTestUrl,
      queryParameters: <String, String>{'query': 'foo'},
      cancelToken: anyNamed('cancelToken'),
    )).called(1);
  });

  test('lang & release', () async {
    final dio = MockDio();
    when(dio.get(
      kTestUrl,
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => jsonResponse(copenhagen));

    final geoname = Geoname(
      url: kTestUrl,
      geodata: geodata,
      release: 'bar',
      lang: 'baz',
      dio: dio,
    );

    await geoname.search('foo');
    verify(dio.get(
      kTestUrl,
      queryParameters: <String, String>{
        'query': 'foo',
        'release': 'bar',
        'lang': 'baz',
      },
      cancelToken: anyNamed('cancelToken'),
    )).called(1);
  });

  test('error', () async {
    final dio = MockDio();
    when(dio.get(
      kTestUrl,
      queryParameters: anyNamed('queryParameters'),
      cancelToken: anyNamed('cancelToken'),
    )).thenAnswer((_) async => errorResponse);

    final geoname = Geoname(
      url: kTestUrl,
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
