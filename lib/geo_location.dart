class GeoLocation {
  GeoLocation({
    this.name,
    this.admin1,
    this.country,
    this.longitude,
    this.latitude,
  });

  final String? name;
  final String? admin1;
  final String? country;
  final double? longitude;
  final double? latitude;

  GeoLocation copyWith({
    String? name,
    String? admin1,
    String? country,
    double? longitude,
    double? latitude,
  }) {
    return GeoLocation(
      name: name ?? this.name,
      admin1: admin1 ?? this.admin1,
      country: country ?? this.country,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'admin1': admin1,
      'country': country,
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> map) {
    return GeoLocation(
      name: map['name'],
      admin1: map['admin1'],
      country: map['country'],
      longitude: double.tryParse(map['longitude']),
      latitude: double.tryParse(map['latitude']),
    );
  }

  @override
  String toString() =>
      'GeoLocation(name: $name, admin1: $admin1, country: $country, longitude: $longitude, latitude: $latitude)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoLocation &&
        other.name == name &&
        other.admin1 == admin1 &&
        other.country == country &&
        other.longitude == longitude &&
        other.latitude == latitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      name.hashCode,
      admin1.hashCode,
      country.hashCode,
      longitude.hashCode,
      latitude.hashCode,
    );
  }
}
