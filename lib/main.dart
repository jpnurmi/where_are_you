import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'geo_data.dart';
import 'geo_service.dart';
import 'time_zone_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final geodata = Geodata(
    loadCities: () => rootBundle.loadString('assets/cities15000.txt'),
    loadAdmins: () => rootBundle.loadString('assets/admin1CodesASCII.txt'),
    loadCountries: () => rootBundle.loadString('assets/countryInfo.txt'),
  );

  runApp(Provider(
    create: (_) => GeoService(geodata),
    child: const MaterialApp(home: Builder(builder: TimeZonePage.create)),
  ));
}
