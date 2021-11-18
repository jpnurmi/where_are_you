import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'geo_location.dart';
import 'geo_service.dart';
import 'where_are_you_model.dart';

class FakeLocalizations {
  String geoLocationFormat(String city, String country) => '$city ($country)';
}

final lang = FakeLocalizations();

class WhereAreYouPage extends StatefulWidget {
  const WhereAreYouPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final service = Provider.of<GeoService>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => WhereAreYouModel(service),
      child: const WhereAreYouPage(),
    );
  }

  @override
  State<WhereAreYouPage> createState() => _WhereAreYouPageState();
}

class _WhereAreYouPageState extends State<WhereAreYouPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<WhereAreYouModel>(context);

    String geoLocationToString(GeoLocation? location) {
      if (location == null) return '';
      return lang.geoLocationFormat(
          location.name ?? '', location.country ?? '');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Where are you?')),
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
