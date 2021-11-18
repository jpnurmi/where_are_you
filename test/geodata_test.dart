import 'package:flutter_test/flutter_test.dart';
import 'package:where_are_you/geo_data.dart';

import 'test_geodata.dart';

void main() {
  test('search', () async {
    final data = Geodata(
      loadCities: () => kCities,
      loadAdmins: () => kAdmins,
      loadCountries: () => kCountries,
    );

    await data.search('').then((result) => expect(result, isEmpty));

    await data.search('o').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Oslo');
      expect(result.single.admin, 'Oslo');
      expect(result.single.country, 'Norway');
      expect(result.single.country2, 'NO');
    });

    await data.search('ST').then((result) {
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

    await data.search('Stock').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Stockholm');
      expect(result.single.admin, 'Stockholm');
      expect(result.single.country, 'Sweden');
      expect(result.single.country2, 'SE');
    });

    await data.search('stockfoo').then((result) => expect(result, isEmpty));

    await data.search('uusi').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Helsinki');
      expect(result.single.admin, 'Uusimaa');
      expect(result.single.country, 'Finland');
      expect(result.single.country2, 'FI');
    });

    await data.search('Hel uus FIN').then((result) {
      expect(result.length, 1);
      expect(result.single.name, 'Helsinki');
      expect(result.single.admin, 'Uusimaa');
      expect(result.single.country, 'Finland');
      expect(result.single.country2, 'FI');
    });

    await data.search('Hel foo FIN').then((result) => expect(result, isEmpty));
  });

  test('country2', () async {
    final data = Geodata(
      loadCities: () => kCities,
      loadAdmins: () => kAdmins,
      loadCountries: () => kCountries,
    );

    expect(await data.country2('Denmark'), equals('DK'));
    expect(await data.country2('Finland'), equals('FI'));
    expect(await data.country2('Iceland'), equals('IS'));
    expect(await data.country2('Norway'), equals('NO'));
    expect(await data.country2('Sweden'), equals('SE'));
  });
}
