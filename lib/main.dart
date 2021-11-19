import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:where_are_you/geo_ip.dart';
import 'package:where_are_you/geo_name.dart';

import 'geo_data.dart';
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
  final service = GeoService(geoip)
    ..addSource(geodata)
    ..addSource(geoname);

  runApp(
    Provider.value(
      value: service,
      builder: (ctx, _) => MaterialApp(home: WhereAreYouPage.create(ctx)),
    ),
  );
}
