import 'package:flutter_test/flutter_test.dart';
import 'package:where_are_you/geo_location.dart';

import 'test_geodata.dart';

void main() {
  test('search', () async {
    await geodata.search('').then((result) => expect(result, isEmpty));

    await geodata.search('o').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Oslo');
      expect(result.single.admin, 'Oslo');
      expect(result.single.country, 'Norway');
      expect(result.single.country2, 'NO');
    });

    await geodata.search('ST').then((result) {
      expect(result.length, 2);
      expect(result.first.name, 'Stavanger');
      expect(result.first.admin, isNull);
      expect(result.first.country, 'Norway');
      expect(result.first.country2, 'NO');
      expect(result.last.name, 'Stockholm');
      expect(result.last.admin, 'Stockholm');
      expect(result.last.country, 'Sweden');
      expect(result.last.country2, 'SE');
    });

    await geodata.search('Stock').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Stockholm');
      expect(result.single.admin, 'Stockholm');
      expect(result.single.country, 'Sweden');
      expect(result.single.country2, 'SE');
    });

    await geodata.search('stockfoo').then((result) => expect(result, isEmpty));

    await geodata.search('uusi').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Helsinki');
      expect(result.single.admin, 'Uusimaa');
      expect(result.single.country, 'Finland');
      expect(result.single.country2, 'FI');
    });

    await geodata.search('Hel uus FIN').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Helsinki');
      expect(result.single.admin, 'Uusimaa');
      expect(result.single.country, 'Finland');
      expect(result.single.country2, 'FI');
    });

    await geodata
        .search('Hel foo FIN')
        .then((result) => expect(result, isEmpty));
  });

  test('json', () async {
    expect(
      await geodata.fromJson(<String, dynamic>{
        'name': 'Copenhagen',
        'admin1': 'Capital Region',
        'country': 'Denmark',
        'latitude': '55.67594',
        'longitude': '12.56553',
        'timezone': 'Europe/Copenhagen',
      }),
      copenhagen,
    );

    expect(
      await geodata.fromJson(<String, dynamic>{
        'latitude': 55.67594,
        'longitude': 12.56553,
      }),
      const GeoLocation(
        latitude: 55.67594,
        longitude: 12.56553,
      ),
    );
  });

  test('xml', () async {
    expect(
      await geodata.fromXml('''
<Response>
  <Ip>127.0.0.1</Ip>
  <Status>OK</Status>
  <CountryCode>SE</CountryCode>
  <CountryCode3>SWE</CountryCode3>
  <CountryName>Sweden</CountryName>
  <RegionCode>28</RegionCode>
  <RegionName>Vastra Gotaland</RegionName>
  <City>Göteborg</City>
  <ZipPostalCode>416 66</ZipPostalCode>
  <Latitude>57.70716</Latitude>
  <Longitude>11.96679</Longitude>
  <AreaCode>0</AreaCode>
  <TimeZone>Europe/Stockholm</TimeZone>
</Response>
'''),
      GeoLocation(
        name: 'Göteborg',
        admin: 'Vastra Gotaland',
        country: 'Sweden',
        country2: 'SE',
        latitude: 57.70716,
        longitude: 11.96679,
        timezone: 'Europe/Stockholm',
      ),
    );

    expect(
      await geodata.fromXml('''
<Response>
  <Ip>127.0.0.1</Ip>
  <Status>OK</Status>
  <City>Göteborg</City>
</Response>
'''),
      GeoLocation(
        name: 'Göteborg',
        admin: null,
        country: null,
        country2: null,
        latitude: null,
        longitude: null,
        timezone: null,
      ),
    );

    expect(
      await geodata.fromXml('''
<Response>
  <Ip>127.0.0.1</Ip>
  <Status>ERROR</Status>
</Response>
'''),
      isNull,
    );
  });
}
