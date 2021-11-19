import 'package:flutter_test/flutter_test.dart';

import 'test_geodata.dart';

void main() {
  test('copy with', () async {
    final copy1 = copenhagen.copyWith(
      admin: gothenburg.admin,
      country: gothenburg.country,
      longitude: gothenburg.longitude,
      timezone: gothenburg.timezone,
    );
    expect(copy1.name, copenhagen.name);
    expect(copy1.admin, gothenburg.admin);
    expect(copy1.country, gothenburg.country);
    expect(copy1.country2, copenhagen.country2);
    expect(copy1.latitude, copenhagen.latitude);
    expect(copy1.longitude, gothenburg.longitude);
    expect(copy1.timezone, gothenburg.timezone);

    final copy2 = gothenburg.copyWith(
      name: copenhagen.name,
      admin: copenhagen.admin,
      country: copenhagen.country,
      country2: copenhagen.country2,
      latitude: copenhagen.latitude,
      longitude: copenhagen.longitude,
      timezone: copenhagen.timezone,
    );
    expect(copy2, copenhagen);

    final copy3 = copenhagen.copyWith();
    expect(copy3, copenhagen);
  });

  test('string', () {
    final str = copenhagen.toString();
    expect(str.contains(copenhagen.runtimeType.toString()), isTrue);
    expect(str.contains(copenhagen.name!), isTrue);
    expect(str.contains(copenhagen.admin!), isTrue);
    expect(str.contains(copenhagen.country!), isTrue);
    expect(str.contains(copenhagen.country2!), isTrue);
    expect(str.contains(copenhagen.latitude!.toString()), isTrue);
    expect(str.contains(copenhagen.longitude!.toString()), isTrue);
    expect(str.contains(copenhagen.timezone!), isTrue);
  });
}
