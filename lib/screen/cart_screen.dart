import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/model/api.dart';
import 'package:test5/model/cart.dart';

import 'login_screen.dart';
import 'order_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("fullName") != null;
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<CartModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Không có sản phẩm nào'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.network(
                          '${url.api}/images/${cart.items[index].product.image}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(cart.items[index].product.name),
                        subtitle:
                            Text('Số lượng: ${cart.items[index].quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cart.decrementQuantity(cart.items[index]);
                              },
                            ),
                            Text('${cart.items[index].quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cart.incrementQuantity(cart.items[index]);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_shopping_cart),
                              onPressed: () {
                                cart.removeProduct(cart.items[index].product);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Tổng tiền: ${cart.totalPrice} đ',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      bool loggedIn = await isLoggedIn();
                      if (!loggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderScreen(cart: cart),
                          ),
                        );
                      }
                    },
                    child: const Text('Mua ngay'),
                  ),
                ),
              ],
            ),
    );
  }
}
