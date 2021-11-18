import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'geo_location.dart';
import 'geo_service.dart';
import 'network_service.dart';
import 'where_are_you_model.dart';

class FakeLocalizations {
  String geoLocationCity(String city) => city;
  String geoLocationCityAdmin(String city, String admin) => '$city ($admin)';
  String geoLocationCityCountry(String city, String country) =>
      '$city ($country)';
  String geoLocationCityAdminCountry(
          String city, String admin, String country) =>
      '$city ($admin, $country)';
}

final lang = FakeLocalizations();

class WhereAreYouPage extends StatefulWidget {
  const WhereAreYouPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WhereAreYouModel(
        geo: Provider.of<GeoService>(context, listen: false),
        network: Provider.of<NetworkService>(context, listen: false),
      ),
      child: const WhereAreYouPage(),
    );
  }

  @override
  State<WhereAreYouPage> createState() => _WhereAreYouPageState();
}

class _WhereAreYouPageState extends State<WhereAreYouPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<WhereAreYouModel>(context, listen: false).init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<WhereAreYouModel>(context);

    String geoLocationToString(GeoLocation? location) {
      if (location == null || location.name?.isEmptyOrNull == true) return '';
      if (location.country.isEmptyOrNull && location.admin1.isEmptyOrNull) {
        return lang.geoLocationCity(location.name!);
      }
      if (location.admin1.isEmptyOrNull) {
        return lang.geoLocationCityCountry(location.name!, location.country!);
      }
      if (location.country.isEmptyOrNull) {
        return lang.geoLocationCityAdmin(location.name!, location.admin1!);
      }
      return lang.geoLocationCityAdminCountry(
        location.name!,
        location.admin1!,
        location.country!,
      );
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
      floatingActionButton: Row(
        children: [
          const Spacer(),
          const Text('Online'),
          Switch(
            value: model.isOnline,
            onChanged: (v) => model.setOnline(v),
          ),
        ],
      ),
    );
  }
}

extension _StringEmptyOrNull on String? {
  bool get isEmptyOrNull => this == null || this!.isEmpty;
}
