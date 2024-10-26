import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/model/product.dart';
import 'package:http/http.dart' as http;
import 'package:test5/model/api.dart';

import '../model/cart.dart';
import 'Product_Detail_screen.dart';
import 'login_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Product> favoriteProducts = [];
  bool isLoading = true; // Để theo dõi trạng thái tải dữ liệu

  @override
  void initState() {
    super.initState();
    fetchFavoriteProducts();
  }

  Future<void> fetchFavoriteProducts() async {
    final prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("accId");
    if (accountId != null) {
      try {
        final response =
            await http.get(Uri.parse('${url.api}/api/favorite/$accountId'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            favoriteProducts = (data['result'] as List)
                .map((product) => Product.fromJson(product))
                .toList();
          });
        } else {
          throw Exception('Không thể yêu thích sản phẩm');
        }
      } catch (e) {
        // Xử lý lỗi tải dữ liệu nếu cần
        print(e.toString());
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Future<void> fetchFavoriteStatus(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("accId");

    if (accountId != null) {
      final response = await http.get(
        Uri.parse('${url.api}/api/favorite/$accountId/$productId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          favoriteProducts.firstWhere((product) => product.id == productId).isFavorite =
          data['status'];
        });
      }
    }
  }
  Future<void> toggleFavorite(Product product) async {
    var prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("accId");

    if (accountId != null) {
      final response = await http.post(
        Uri.parse('${url.api}/api/favorite'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'account_id': accountId,
          'product_id': product.id,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          product.isFavorite = !product.isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['result'])),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách đã Yêu thích'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteProducts.isEmpty
              ? const Center(child: Text('Không có sản phẩm yêu thích nào'))
              : GridView.count(
                  padding: const EdgeInsets.all(3),
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.5,
                  shrinkWrap: true,
                  children: List.generate(
                    favoriteProducts.length,
                    (index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: favoriteProducts[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6.0),
                            Image.network(
                              '${url.api}/images/${favoriteProducts[index].image}',
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              ' ${favoriteProducts[index].name}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (favoriteProducts[index].salePrice > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Giá: ${favoriteProducts[index].price}đ',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    'Giảm giá: ${favoriteProducts[index].salePrice}đ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text('Giá: ${favoriteProducts[index].price}đ'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: () {
                                    Provider.of<CartModel>(context,
                                            listen: false)
                                        .addProduct(favoriteProducts[index]);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Đã thêm vào giỏ hàng')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    favoriteProducts[index].isFavorite
                                        ? Icons.favorite_border
                                        : Icons.favorite,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    toggleFavorite(favoriteProducts[index]);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
