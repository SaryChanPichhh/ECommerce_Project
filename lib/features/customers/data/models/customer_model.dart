import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({required super.id, required super.name, super.email, super.phone, super.address, super.company, super.createdAt, super.updatedAt});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      company: json['company'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email, 'phone': phone, 'address': address, 'company': company};

  factory CustomerModel.fromEntity(Customer c) => CustomerModel(id: c.id, name: c.name, email: c.email, phone: c.phone, address: c.address, company: c.company, createdAt: c.createdAt, updatedAt: c.updatedAt);
}
