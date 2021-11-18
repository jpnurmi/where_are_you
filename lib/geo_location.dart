import 'package:xml/xml.dart';

class GeoLocation {
  GeoLocation({
    this.name,
    this.admin,
    this.country,
    this.country2,
    this.latitude,
    this.longitude,
    this.timezone,
  });

  final String? name;
  final String? admin;
  final String? country;
  final String? country2;
  final double? latitude;
  final double? longitude;
  final String? timezone;

  GeoLocation copyWith({
    String? name,
    String? admin,
    String? country,
    String? country2,
    double? latitude,
    double? longitude,
    String? timezone,
  }) {
    return GeoLocation(
      name: name ?? this.name,
      admin: admin ?? this.admin,
      country: country ?? this.country,
      country2: country2 ?? this.country2,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admin1': admin,
      'country': country,
      'country2': country2,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> map) {
    return GeoLocation(
      name: map['name'],
      admin: map['admin1'],
      country: map['country'],
      country2: map['country2'],
      latitude: double.tryParse(map['latitude']),
      longitude: double.tryParse(map['longitude']),
      timezone: map['timezone'],
    );
  }

  static GeoLocation? fromXml(String xml) {
    try {
      final element = XmlDocument.parse(xml).rootElement;
      if (element.getTextOrNull('Status') != 'OK') return null;
      return GeoLocation(
        name: element.getTextOrNull('City'),
        admin: element.getTextOrNull('CountryRegionName'),
        country: element.getTextOrNull('CountryName'),
        country2: element.getTextOrNull('CountryCode'),
        latitude: element.getDoubleOrNull('Latitude'),
        longitude: element.getDoubleOrNull('Longitude'),
        timezone: element.getTextOrNull('TimeZone'),
      );
    } on XmlException {
      return null;
    }
  }

  @override
  String toString() =>
      'GeoLocation(name: $name, admin: $admin, country: $country, country2: $country2, latitude: $latitude, longitude: $longitude, timezone: $timezone)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        other.name == name &&
        other.admin == admin &&
        other.country == country &&
        other.country2 == country2 &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timezone == timezone;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      admin,
      country,
      country2,
      latitude,
      longitude,
      timezone,
    );
  }
}

extension _XmlElementX on XmlElement? {
  String? getTextOrNull(String name) => this?.getElement(name)?.text;
  double? getDoubleOrNull(String name) =>
      double.tryParse(getTextOrNull(name) ?? '');
}
