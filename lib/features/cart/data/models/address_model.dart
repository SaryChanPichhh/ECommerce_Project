import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    super.userId,
    super.label,
    required super.recipientName,
    required super.phoneNumber,
    required super.addressLine1,
    super.addressLine2,
    required super.city,
    super.state,
    super.postalCode,
    super.countryCode,
    super.latitude,
    super.longitude,
    super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    return AddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      label: json['label'] as String?,
      recipientName: json['recipient_name'] as String? ?? 'Recipient',
      phoneNumber: json['phone_number'] as String? ?? '',
      addressLine1: json['address_line_1'] as String? ?? json['address'] as String? ?? '',
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String? ?? 'Phnom Penh',
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      countryCode: json['country_code'] as String? ?? 'KH',
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (label != null) 'label': label,
      'recipient_name': recipientName,
      'phone_number': phoneNumber,
      'address_line_1': addressLine1,
      if (addressLine2 != null) 'address_line_2': addressLine2,
      'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      'country_code': countryCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_default': isDefault,
    };
  }
}
