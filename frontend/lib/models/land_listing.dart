class LandListing {
  final int id;
  final int userId;
  final String? userName;
  final String? userEmail;
  final String title;
  final double sizeAcres;
  final double sizeHectares;
  final int countyId;
  final String? countyName;
  final int subcountyId;
  final String? subcountyName;
  final String availability;
  final String? imageUrl;
  final List<RestorationType> restorationTypes;
  final String createdAt;
  final String updatedAt;

  LandListing({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.title,
    required this.sizeAcres,
    required this.sizeHectares,
    required this.countyId,
    this.countyName,
    required this.subcountyId,
    this.subcountyName,
    required this.availability,
    this.imageUrl,
    required this.restorationTypes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LandListing.fromJson(Map<String, dynamic> json) {
    return LandListing(
      id: json['id'],
      userId: json['user'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      title: json['title'],
      sizeAcres: double.parse(json['size_acres'].toString()),
      sizeHectares: double.parse(json['size_hectares'].toString()),
      countyId: json['county'],
      countyName: json['county_name'],
      subcountyId: json['subcounty'],
      subcountyName: json['subcounty_name'],
      availability: json['availability'],
      imageUrl: json['image_url'],
      restorationTypes: (json['restoration_types'] as List)
          .map((e) => RestorationType.fromJson(e))
          .toList(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  bool get isAvailable => availability == 'available';
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