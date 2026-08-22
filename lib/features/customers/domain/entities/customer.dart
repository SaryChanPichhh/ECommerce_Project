class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? company;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.company,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is Customer && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
