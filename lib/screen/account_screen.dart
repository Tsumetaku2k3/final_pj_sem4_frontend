import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/screen/accont_detail_screen.dart';
import '../model/api.dart';
import 'login_screen.dart';
import 'order_management_screen.dart';
import 'order_status_screen.dart';
import 'package:http/http.dart' as http;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoggedIn = false;
  String? _fullName;
  int? _accountId;
  List _orders = [];

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      _fullName = pref.getString("fullName");
      _accountId = pref.getInt("accId");
      if (_accountId != null) {
        _fetchOrders();
      }
    });
    checkLoginStatus();
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

  Future<void> _fetchOrders() async {
    if (_accountId == null) return;

    try {
      final response = await http.get(
        Uri.parse('${url.api}/api/orders-account/$_accountId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _orders = responseData['result'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load orders')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _navigateToOrderStatusScreen(String status) {
    final filteredOrders = _orders.where((order) => order['status'] == status).toList();
    if (filteredOrders.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderStatusScreen(orders: filteredOrders),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No orders with status "$status" found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            if (isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountDetailScreen(),
                ),
              );
            }
          },
          child: Text(
            'Xin chào: $_fullName',
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () => _navigateToOrderStatusScreen('Chờ xác nhận'),
                    child: const Icon(Icons.wallet),
                  ),
                  const SizedBox(width: 20.0),
                  FloatingActionButton(
                    onPressed: () => _navigateToOrderStatusScreen('Chờ lấy hàng'),
                    child: const Icon(Icons.backpack),
                  ),
                  const SizedBox(width: 20.0),
                  FloatingActionButton(
                    onPressed: () => _navigateToOrderStatusScreen('Chờ giao hàng'),
                    child: const Icon(Icons.fire_truck),
                  ),
                  const SizedBox(width: 20.0),
                  FloatingActionButton(
                    onPressed: () => _navigateToOrderStatusScreen('Đã hủy'),
                    child: const Icon(Icons.cancel),
                  ),
                ],
              ),
            ),
            if (isLoggedIn) ...[
              const SizedBox(height: 20.0),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Lịch sử Đơn hàng'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderManagementScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Đăng xuất'),
                onTap: () async {
                  await logout();
                },
              ),
            ] else ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Bạn chưa đăng nhập',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
