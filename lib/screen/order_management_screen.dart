import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/model/api.dart';
import 'package:intl/intl.dart';

import 'order_details_screen.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  bool _isLoading = true;
  List _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<int> _getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('accId') ?? 0;
  }

  Future<void> _fetchOrders() async {
    final accountId = await _getAccountId();

    if (accountId == 0) {
      _showSnackBar('Không tìm thấy ID tài khoản');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${url.api}/api/orders-account/$accountId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _orders = responseData['result'];
          _isLoading = false;
        });
      } else {
        _showSnackBar(
            'Không thể tải được thông tin đặt hàng: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Đã xảy ra lỗi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('${url.api}/api/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'Đã hủy'}),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Đơn hàng đã được hủy thành công');
        _fetchOrders();
      } else {
        _showSnackBar('Không thể hủy đơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Đã xảy ra lỗi: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildOrderTile(Map order) {
    return ListTile(
      title: Text('Mã đơn hàng: ${order['id']}'),
      subtitle: Text(
        'Tổng tiền: ${order['total_price']} đ\nNgày đặt: ${_formatDate(order['created_at'])}',
        style: const TextStyle(fontSize: 16),
      ),
      trailing: Wrap(
        spacing: 9,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Trạng thái: ${order['status']}',
                style: const TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              if (order['status'] == 'Chờ xác nhận')
                TextButton(
                  onPressed: () => _cancelOrder(order['id']),
                  child: const Text(
                    'Hủy đơn',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(
              orderId: order['id'],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Đơn hàng'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('Không tìm thấy đơn hàng nào'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return _buildOrderTile(order);
                  },
                ),
    );
  }
}
