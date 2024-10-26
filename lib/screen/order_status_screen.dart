import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test5/model/api.dart';
import 'package:intl/intl.dart';

import 'order_details_screen.dart';

class OrderStatusScreen extends StatefulWidget {
  final List orders;

  const OrderStatusScreen({super.key, required this.orders});

  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final bool _isLoading = false;

  Future<void> _cancelOrder(int orderId) async {
    try {
      final response = await http.put(
        Uri.parse('${url.api}/api/orders/$orderId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': 'Canceled'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đơn hàng đã hủy thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Không thể hủy đơn hàng: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                '${order['status']}',
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
          : widget.orders.isEmpty
              ? const Center(child: Text('Không tìm thấy đơn hàng nào'))
              : ListView.builder(
                  itemCount: widget.orders.length,
                  itemBuilder: (context, index) {
                    final order = widget.orders[index];
                    return _buildOrderTile(order);
                  },
                ),
    );
  }
}
