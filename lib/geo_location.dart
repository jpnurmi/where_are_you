import 'package:xml/xml.dart';

class GeoLocation {
  GeoLocation({
    this.name,
    this.admin1,
    this.country,
    this.latitude,
    this.longitude,
  });

  final String? name;
  final String? admin1;
  final String? country;
  final double? latitude;
  final double? longitude;

  GeoLocation copyWith({
    String? name,
    String? admin1,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    return GeoLocation(
      name: name ?? this.name,
      admin1: admin1 ?? this.admin1,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admin1': admin1,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> map) {
    return GeoLocation(
      name: map['name'],
      admin1: map['admin1'],
      country: map['country'],
      latitude: double.tryParse(map['latitude']),
      longitude: double.tryParse(map['longitude']),
    );
  }

  static GeoLocation? fromXml(String xml) {
    try {
      final element = XmlDocument.parse(xml).rootElement;
      if (element.getTextOrNull('Status') != 'OK') return null;
      return GeoLocation(
        name: element.getTextOrNull('City'),
        admin1: element.getTextOrNull('CountryRegionName'),
        country: element.getTextOrNull('CountryName'),
        latitude: element.getDoubleOrNull('Latitude'),
        longitude: element.getDoubleOrNull('Longitude'),
      );
    } on XmlException {
      return null;
    }
  }

  @override
  String toString() =>
      'GeoLocation(name: $name, admin1: $admin1, country: $country, latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        other.name == name &&
        other.admin1 == admin1 &&
        other.country == country &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      name.hashCode,
      admin1.hashCode,
      country.hashCode,
      latitude.hashCode,
      longitude.hashCode,
    );
  }
}

extension _XmlElementX on XmlElement? {
  String? getTextOrNull(String name) => this?.getElement(name)?.text;
  double? getDoubleOrNull(String name) =>
      double.tryParse(getTextOrNull(name) ?? '');
}
