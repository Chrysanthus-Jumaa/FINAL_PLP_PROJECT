class MatchRequest {
  final int id;
  final int organizationId;
  final String? organizationName;
  final String? organizationEmail;
  final int restorerId;
  final String? restorerName;
  final String? restorerEmail;
  final String? restorerPhone;
  final int landListingId;
  final String? landListingTitle;
  final Map<String, dynamic>? landListingDetails;
  final String status;
  final String createdAt;
  final String updatedAt;

  MatchRequest({
    required this.id,
    required this.organizationId,
    this.organizationName,
    this.organizationEmail,
    required this.restorerId,
    this.restorerName,
    this.restorerEmail,
    this.restorerPhone,
    required this.landListingId,
    this.landListingTitle,
    this.landListingDetails,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchRequest.fromJson(Map<String, dynamic> json) {
    return MatchRequest(
      id: json['id'],
      organizationId: json['organization'],
      organizationName: json['organization_name'],
      organizationEmail: json['organization_email'],
      restorerId: json['restorer'],
      restorerName: json['restorer_name'],
      restorerEmail: json['restorer_email'],
      restorerPhone: json['restorer_phone'],
      landListingId: json['land_listing'],
      landListingTitle: json['land_listing_title'],
      landListingDetails: json['land_listing_details'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isLandNoLongerAvailable => status == 'land_no_longer_available';
}