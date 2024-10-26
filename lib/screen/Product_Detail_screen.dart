import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/model/api.dart';
import 'package:test5/model/cart.dart';
import 'package:test5/model/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
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
            'product_id': widget.product.id,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            widget.product.isFavorite = !widget.product.isFavorite;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['result'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to toggle favorite')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network(
                '${url.api}/images/${widget.product.image}',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                widget.product.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.product.salePrice > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá: ${widget.product.price}đ',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Giá khuyến mãi: ${widget.product.salePrice}đ',
                      style: const TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                )
              else
                Text(
                  'Giá: ${widget.product.price}đ',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
              const SizedBox(height: 8),
              const Text(
                'Thông tin sản phẩm:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<CartModel>(context, listen: false)
                          .addProduct(widget.product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                      );
                    },
                    child: const Text('Thêm vào giỏ hàng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
