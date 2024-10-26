class Account {
  final int id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final String status;
  final String password;

  Account({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.status,
    required this.password,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      email: json['email'],
      status: json['status'],
      password: json['password'],
    );
  }
}
