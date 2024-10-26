class Order {
  final int id;
  final int accountId;
  final String name;
  final String phone;
  final String address;
  final String note;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.accountId,
    required this.name,
    required this.phone,
    required this.address,
    required this.note,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      accountId: json['account_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      note: json['note'],
      totalPrice: json['total_price'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'name': name,
      'phone': phone,
      'address': address,
      'note': note,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
