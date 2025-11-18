class User {
  final int id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? organizationName;
  final String? phone;
  final int? countyId;
  final String? countyName;
  final int? subcountyId;
  final String? subcountyName;
  final List<RestorationType>? restorationTypes;
  final String createdAt;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.organizationName,
    this.phone,
    this.countyId,
    this.countyName,
    this.subcountyId,
    this.subcountyName,
    this.restorationTypes,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      organizationName: json['organization_name'],
      phone: json['phone'],
      countyId: json['county'],
      countyName: json['county_name'],
      subcountyId: json['subcounty'],
      subcountyName: json['subcounty_name'],
      restorationTypes: json['restoration_types'] != null
          ? (json['restoration_types'] as List)
              .map((e) => RestorationType.fromJson(e))
              .toList()
          : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'organization_name': organizationName,
      'phone': phone,
      'county': countyId,
      'county_name': countyName,
      'subcounty': subcountyId,
      'subcounty_name': subcountyName,
      'restoration_types': restorationTypes?.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
    };
  }

  String get displayName {
    if (role == 'restorer') {
      return '$firstName $lastName';
    }
    return organizationName ?? email;
  }

  String get initials {
    if (role == 'restorer' && firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (organizationName != null && organizationName!.length >= 2) {
      final words = organizationName!.split(' ');
      if (words.length >= 2) {
        return '${words[0][0]}${words[1][0]}'.toUpperCase();
      }
      return organizationName!.substring(0, 2).toUpperCase();
    }
    return email.substring(0, 2).toUpperCase();
  }
}

class RestorationType {
  final int id;
  final String name;
  final String displayName;

  RestorationType({
    required this.id,
    required this.name,
    required this.displayName,
  });

  factory RestorationType.fromJson(Map<String, dynamic> json) {
    return RestorationType(
      id: json['id'],
      name: json['name'],
      displayName: json['display_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
    };
  }
}

class County {
  final int id;
  final String name;

  County({required this.id, required this.name});

  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Subcounty {
  final int id;
  final String name;
  final int countyId;
  final String? countyName;

  Subcounty({
    required this.id,
    required this.name,
    required this.countyId,
    this.countyName,
  });

  factory Subcounty.fromJson(Map<String, dynamic> json) {
    return Subcounty(
      id: json['id'],
      name: json['name'],
      countyId: json['county'],
      countyName: json['county_name'],
    );
  }
}