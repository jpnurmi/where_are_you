import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'geo_location.dart';
import 'geo_service.dart';
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
      if (location.country.isEmptyOrNull && location.admin.isEmptyOrNull) {
        return lang.geoLocationCity(location.name!);
      }
      if (location.admin.isEmptyOrNull) {
        return lang.geoLocationCityCountry(location.name!, location.country!);
      }
      if (location.country.isEmptyOrNull) {
        return lang.geoLocationCityAdmin(location.name!, location.admin!);
      }
      return lang.geoLocationCityAdminCountry(
        location.name!,
        location.admin!,
        location.country!,
      );
    }

    final answer = model.selectedLocation != null
        ? '- ${model.selectedLocation?.country} (${model.selectedLocation?.country2})'
        : '';

    return Scaffold(
      appBar: AppBar(title: Text('Where are you? $answer')),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: model.isInitialized
              ? Autocomplete<GeoLocation>(
                  initialValue: TextEditingValue(
                      text: geoLocationToString(model.selectedLocation)),
                  displayStringForOption: geoLocationToString,
                  optionsBuilder: (value) => model.searchLocation(value.text),
                  onSelected: (location) => model.selectLocation(location),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

extension _StringEmptyOrNull on String? {
  bool get isEmptyOrNull => this == null || this!.isEmpty;
}
