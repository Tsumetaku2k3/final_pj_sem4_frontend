import 'package:flutter/material.dart';
import 'package:test5/model/api.dart';
import 'package:test5/model/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'order_management_screen.dart';

class OrderScreen extends StatefulWidget {
  final CartModel cart;

  const OrderScreen({super.key, required this.cart});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAccountDetails();
  }

  Future<int> _getAccountId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('accId') ?? 0; // Retrieve the account ID
  }

  Future<void> _fetchAccountDetails() async {
    setState(() {
      _isLoading = true;
    });

    final accountId = await _getAccountId();

    if (accountId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account ID not found')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${url.api}/api/account/$accountId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Access the 'result' object from the responseData
        final result = responseData['result'];

        if (result != null) {
          _nameController.text = result['name'] ?? '';
          _phoneController.text = result['phone'] ?? '';
          _addressController.text = result['address'] ?? '';
        } else {
          print('Result is null in the response');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch account details: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _placeOrder() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final note = _noteController.text.trim();
    final totalPrice = widget.cart.totalPrice;

    if (phone.isEmpty || address.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final accountId = await _getAccountId();

    if (accountId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account ID not found')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final order = {
      'account_id': accountId,
      'name': name,
      'phone': phone,
      'address': address,
      'note': note,
      'total_price': totalPrice,
    };

    try {
      final response = await http.post(
        Uri.parse('${url.api}/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['result'] != null) {
          final orderId = responseData['result']['id'];

          for (var detail in widget.cart.items) {
            final orderDetail = {
              'order_id': orderId,
              'product_id': detail.product.id,
              'quantity': detail.quantity,
            };

            await http.post(
              Uri.parse('${url.api}/api/order-details'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(orderDetail),
            );
          }

          widget.cart.clearCart();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt đơn thành công')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OrderManagementScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected response format')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin đơn hàng cần xác nhận'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Chú thích'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _placeOrder,
              child: const Text('Đặt hàng ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
