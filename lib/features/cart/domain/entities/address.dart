class Address {
  final String id;
  final String? userId;
  final String? label;
  final String recipientName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String countryCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const Address({
    required this.id,
    this.userId,
    this.label,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    this.countryCode = 'KH',
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      if (state != null && state!.isNotEmpty) state!,
      city,
    ];
    return parts.join(', ');
  }
}
