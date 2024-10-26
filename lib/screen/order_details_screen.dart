import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:test5/model/api.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = true;
  List _orderItems = [];
  Map<String, dynamic>? _orders;

  @override
  void initState() {
    super.initState();
    _fetchOrderItems();
    _fetchOrders();
  }

  Future<void> _fetchOrderItems() async {
    try {
      final response = await http.get(
        Uri.parse('${url.api}/api/order-details-by-order/${widget.orderId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _orderItems = responseData['result'];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tìm thấy các đơn hàng: ${response.statusCode}'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('${url.api}/api/orders/${widget.orderId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orders = data['result'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải thông tin đơn hàng'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
        ),
      );
    }
  }
  String _formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      // If parsing or formatting fails, return the original string or an error message
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin chi tiết đơn hàng'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders == null
          ? const Center(child: Text('Không có dữ liệu đơn hàng'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _orderItems.isEmpty
                ? const Center(child: Text('Không có mục nào trong đơn hàng này'))
                : ListView.builder(
              itemCount: _orderItems.length,
              itemBuilder: (context, index) {
                final item = _orderItems[index];
                final salePrice = item['product_sale_price'];
                final price = (salePrice != null && salePrice > 0) ? salePrice : item['product_price'];

                return ListTile(
                  leading: Image.network(
                    '${url.api}/images/${item['product_image']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text('${item['product_name']}'),
                  subtitle: Text('Giá: $price đ'),
                  trailing: Text('Số lượng: ${item['quantity']}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã đơn hàng: ${_orders!['id']}'),
                Text('Tên người đặt: ${_orders!['name']}'),
                Text('Số điện thoại: ${_orders!['phone']}'),
                Text('Địa chỉ: ${_orders!['address']}'),
                Text('Chú thích: ${_orders!['note']}'),
                Text('Trạng thái đơn hàng: ${_orders!['status']}'),
                Text('Ngày đặt đơn: ${_formatDate(_orders!['created_at'])}'),
                Text('Tổng giá đơn: ${_orders!['total_price']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
