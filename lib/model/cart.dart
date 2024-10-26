import 'package:flutter/material.dart';
import 'package:test5/model/product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartModel with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addProduct(Product product) {
    for (var item in _items) {
      if (item.product.id == product.id) {
        item.quantity++;
        print('Updated quantity for ${product.id}: ${item.quantity}');
        notifyListeners();
        return;
      }
    }
    _items.add(CartItem(product: product));
    print('Added new product ${product.id}');
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    print('Removed product ${product.id}');
    notifyListeners();
  }

  void incrementQuantity(CartItem item) {
    item.quantity++;
    print('Incremented quantity for ${item.product.id}: ${item.quantity}');
    notifyListeners();
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      print('Decremented quantity for ${item.product.id}: ${item.quantity}');
    } else {
      _items.remove(item);
      print('Removed product ${item.product.id}');
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    print('Cart cleared');
    notifyListeners();
  }

  double get totalPrice {
    double total = _items.fold(0, (sum, item) {
      // Sử dụng salePrice nếu không phải 0, ngược lại sử dụng price
      double itemPrice = item.product.salePrice > 0
          ? item.product.salePrice
          : item.product.price;
      double itemTotal = itemPrice * item.quantity;
      print(
          'Product ${item.product.id}: $itemPrice * ${item.quantity} = $itemTotal');
      return sum + itemTotal;
    });
    print('Total price: $total');
    return total;
  }
}
