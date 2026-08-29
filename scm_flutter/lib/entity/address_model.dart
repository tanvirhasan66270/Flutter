class Country {
  final int id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class Division {
  final int id;
  final String name;
  final int countryId;

  Division({required this.id, required this.name, required this.countryId});

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      id: json['id'] as int,
      name: json['name'] as String,
      countryId: json['countryId'] as int,
    );
  }
}

class District {
  final int id;
  final String name;
  final int divisionId;

  District({required this.id, required this.name, required this.divisionId});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      name: json['name'] as String,
      divisionId: json['divisionId'] as int,
    );
  }
}

class PoliceStation {
  final int id;
  final String name;
  final int districtId;

  PoliceStation({required this.id, required this.name, required this.districtId});

  factory PoliceStation.fromJson(Map<String, dynamic> json) {
    return PoliceStation(
      id: json['id'] as int,
      name: json['name'] as String,
      districtId: json['districtId'] as int,
    );
  }
}
