class Product {
  final int id;
  final String name;
  final String image;
  final double price;
  final double salePrice;
  final String description;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.salePrice,
    required this.description,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double salePrice = (json['sale_price'] is int)
        ? (json['sale_price'] as int).toDouble()
        : json['sale_price'] ?? 0.0;

    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'],
      salePrice: salePrice,
      description: json['description'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
