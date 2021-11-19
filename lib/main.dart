import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'geo_service.dart';
import 'where_are_you_page.dart';

const kGeoIPUrl = 'https://geoip.ubuntu.com/lookup';
const kGeonameUrl = 'http://geoname-lookup.ubuntu.com/';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final geodata = Geodata(
    loadCities: () => rootBundle.loadString('assets/cities15000.txt'),
    loadAdmins: () => rootBundle.loadString('assets/admin1CodesASCII.txt'),
    loadCountries: () => rootBundle.loadString('assets/countryInfo.txt'),
  );

  final geoip = GeoIP(url: kGeoIPUrl, geodata: geodata);
  final geoname = Geoname(url: kGeonameUrl, geodata: geodata);

  runApp(
    Provider(
      create: (_) => GeoService(geoip, sources: [geodata, geoname]),
      builder: (ctx, _) => MaterialApp(home: WhereAreYouPage.create(ctx)),
    ),
  );
}
