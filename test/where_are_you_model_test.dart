import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ubuntu_desktop_installer/services.dart';
import 'package:where_are_you/where_are_you_model.dart';

import 'where_are_you_model_test.mocks.dart';

@GenerateMocks([GeoService])
void main() {
  test('init geoip', () async {
    final service = MockGeoService();
    when(service.init()).thenAnswer((_) async => gothenburg);

    final model = WhereAreYouModel(service);
    expect(model.isInitialized, isFalse);

    bool? wasNotified;
    model.addListener(() => wasNotified = true);

    await model.init();
    expect(model.selectedLocation, gothenburg);
    expect(model.isInitialized, isTrue);
    expect(wasNotified, isTrue);
    verify(service.init()).called(1);
  });

  test('unknown geoip', () async {
    final service = MockGeoService();
    when(service.init()).thenAnswer((_) async => null);

    final model = WhereAreYouModel(service);
    expect(model.isInitialized, isFalse);

    bool? wasNotified;
    model.addListener(() => wasNotified = true);

    await model.init();
    expect(model.selectedLocation, isNull);
    expect(model.isInitialized, isTrue);
    expect(wasNotified, isTrue);
    verify(service.init()).called(1);
  });

  test('select location', () {
    final model = WhereAreYouModel(MockGeoService());
    expect(model.selectedLocation, isNull);

    bool? wasNotified;
    model.addListener(() => wasNotified = true);

    model.selectLocation(gothenburg);
    expect(model.selectedLocation, gothenburg);
    expect(wasNotified, isTrue);
  });

  test('search location', () async {
    final service = MockGeoService();
    when(service.search('u')).thenAnswer((_) async => [copenhagen, gothenburg]);

    final model = WhereAreYouModel(service);
    expect(model.locations, isEmpty);

    bool? wasNotified;
    model.addListener(() => wasNotified = true);

    expect(await model.searchLocation(''), []);
    expect(wasNotified, isNull);

    expect(await model.searchLocation('u'), [copenhagen, gothenburg]);
    expect(wasNotified, isTrue);

    wasNotified = null;
    expect(await model.searchLocation('u'), [copenhagen, gothenburg]);
    expect(wasNotified, isNull);
  });
}

const copenhagen = GeoLocation(
  name: 'Copenhagen',
  admin: 'Capital Region',
  country: 'Denmark',
  country2: 'DK',
  latitude: 55.67594,
  longitude: 12.56553,
  timezone: 'Europe/Copenhagen',
);

const gothenburg = GeoLocation(
  name: 'Göteborg',
  admin: 'Vastra Gotaland',
  country: 'Sweden',
  country2: 'SE',
  latitude: 57.70716,
  longitude: 11.96679,
  timezone: 'Europe/Stockholm',
);
