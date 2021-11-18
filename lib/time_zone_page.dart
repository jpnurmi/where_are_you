import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'geo_location.dart';
import 'geo_service.dart';
import 'time_zone_model.dart';

class FakeLocalizations {
  String geoLocationFormat(String city, String country) => '$city ($country)';
}

final lang = FakeLocalizations();

class TimeZonePage extends StatefulWidget {
  const TimeZonePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final service = Provider.of<GeoService>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => TimeZoneModel(service),
      child: const TimeZonePage(),
    );
  }

  @override
  State<TimeZonePage> createState() => _TimeZonePageState();
}

class _TimeZonePageState extends State<TimeZonePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TimeZoneModel>(context);

    String geoLocationToString(GeoLocation? location) {
      if (location == null) return '';
      return lang.geoLocationFormat(
          location.name ?? '', location.country ?? '');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Time Zone')),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: Autocomplete<GeoLocation>(
            displayStringForOption: geoLocationToString,
            optionsBuilder: (value) => model.searchLocation(value.text),
            onSelected: (location) => model.selectLocation(location),
          ),
        ),
      ),
    );
  }
}
