import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:where_are_you/geo_ip.dart';
import 'package:where_are_you/geo_source.dart';
import 'package:where_are_you/geo_service.dart';

import 'geo_service_test.mocks.dart';
import 'test_geodata.dart';

@GenerateMocks([GeoIP, GeoSource])
void main() {
  test('init', () async {
    final geoip = MockGeoIP();
    when(geoip.lookup()).thenAnswer((_) async => copenhagen);

    final service = GeoService(geoip);
    expect(await service.init(), copenhagen);
    verify(geoip.lookup()).called(1);
  });

  test('null', () async {
    final geoip = MockGeoIP();
    when(geoip.lookup()).thenAnswer((_) async => null);

    final service = GeoService(geoip);
    expect(await service.init(), isNull);
    verify(geoip.lookup()).called(1);
  });

  test('sources', () async {
    final source1 = MockGeoSource();
    when(source1.search('foo'))
        .thenAnswer((_) async => [copenhagen, gothenburg]);

    final source2 = MockGeoSource();
    when(source2.search('foo')).thenAnswer((_) async => [copenhagen]);

    final service = GeoService(MockGeoIP());
    expect(await service.search('foo'), []);
    verifyNever(source1.search('foo'));
    verifyNever(source2.search('foo'));

    service.addSource(source1);
    service.addSource(source2);

    expect(await service.search('foo'), [copenhagen, gothenburg]);
    verify(source1.search('foo')).called(1);
    verify(source2.search('foo')).called(1);

    service.removeSource(source1);
    expect(await service.search('foo'), [copenhagen]);
    verifyNever(source1.search('foo'));
    verify(source2.search('foo')).called(1);
  });
}
