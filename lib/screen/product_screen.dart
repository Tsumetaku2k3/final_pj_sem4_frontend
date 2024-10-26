import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test5/model/api.dart';
import 'package:test5/model/cart.dart';
import 'package:test5/model/product.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Product_Detail_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  bool isLoggedIn = false;
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  bool noResultsFound = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    checkLoginStatus();
  }

  Future<void> fetchFavoriteStatus(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("accId");

    if (accountId != null) {
      try {
        final response = await http.get(
          Uri.parse('${url.api}/api/favorite/$accountId/$productId'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            products
                .firstWhere((product) => product.id == productId)
                .isFavorite = data['status'];
          });
        }
      } catch (e) {
        // Handle any errors here
      }
    }
  }

  Future<void> fetchProducts([String query = '']) async {
    setState(() {
      isLoading = true;
      noResultsFound = false;
    });

    try {
      final response =
          await http.get(Uri.parse('${url.api}/api/product?key=$query'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          products = (data['result'] as List)
              .map((product) => Product.fromJson(product))
              .toList();
          noResultsFound = products.isEmpty;
          isLoading = false;
        });
        for (var product in products) {
          fetchFavoriteStatus(product.id);
        }
      } else {
        throw Exception('Không tải được sản phẩm');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        noResultsFound = true;
      });
    }
  }

  Future<void> checkLoginStatus() async {
    var prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt("accId");
    setState(() {
      isLoggedIn = id != null;
    });
  }

  Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> toggleFavorite(Product product) async {
    var prefs = await SharedPreferences.getInstance();
    int? accountId = prefs.getInt("accId");

    if (accountId != null) {
      try {
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
      } catch (e) {
        // Handle any errors here
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
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                fetchProducts(_searchController.text);
              },
            ),
          ),
          onSubmitted: (value) {
            fetchProducts(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noResultsFound
              ? const Center(child: Text('Không tìm thấy kết quả'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                    if (_searchController.text.isEmpty) ...[
                      const SizedBox(height: 25.0),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Sản phẩm giảm giá',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      SizedBox(
                        height: 250, // Height of the horizontal list
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(3),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            if (product.salePrice > 0) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        product: product,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  width: 150,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        '${url.api}/images/${product.image}',
                                        width: double.infinity,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        ' ${product.name}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Giảm giá: ${product.salePrice}đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.add_shopping_cart),
                                            onPressed: () {
                                              Provider.of<CartModel>(context,
                                                      listen: false)
                                                  .addProduct(product);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Đã thêm vào giỏ hàng')),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              product.isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              toggleFavorite(product);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                  ],
    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Sản phẩm mới',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height -
                            320, // Adjusted to fit in available space
                        child: GridView.builder(
                          padding: const EdgeInsets.all(3),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1.5,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(3),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.network(
                                      '${url.api}/images/${product.image}',
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                    Text(
                                      ' ${product.name}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (product.salePrice > 0)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Giá: ${product.price}đ',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          Text(
                                            'Giảm giá: ${product.salePrice}đ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Text(
                                        'Giá: ${product.price}đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add_shopping_cart),
                                          onPressed: () {
                                            Provider.of<CartModel>(context,
                                                    listen: false)
                                                .addProduct(product);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Đã thêm vào giỏ hàng')),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            product.isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            toggleFavorite(product);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
