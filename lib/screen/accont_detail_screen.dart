import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/model/api.dart';
import 'package:test5/screen/login_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({super.key});

  @override
  _AccountDetailScreenState createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  Map<String, dynamic>? accountDetails;
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  TextEditingController? _addressController;
  TextEditingController? _emailController;
  TextEditingController? _statusController;
  TextEditingController? _passwordController;

  @override
  void initState() {
    super.initState();
    _fetchAccountDetails();
  }

  Future<void> _fetchAccountDetails() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt("accId");

    if (id != null) {
      final response = await http.get(Uri.parse('${url.api}/api/account/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          accountDetails = data['result'];
          _nameController = TextEditingController(text: accountDetails!['name']);
          _phoneController = TextEditingController(text: accountDetails!['phone']);
          _addressController = TextEditingController(text: accountDetails!['address']);
          _emailController = TextEditingController(text: accountDetails!['email']);
          _statusController = TextEditingController(text: accountDetails!['status']);
          _passwordController = TextEditingController(text: accountDetails!['password']); // Initialize password controller without the fetched password
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load account details')),
        );
      }
    }
  }

  Future<void> _saveAccountDetails() async {
    final prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt("accId");

    if (id != null) {
      final response = await http.put(
        Uri.parse('${url.api}/api/account/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'name': _nameController!.text,
          'phone': _phoneController!.text,
          'address': _addressController!.text,
          'password': _passwordController!.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu thành công')),
        );
        // Đưa người dùng trở lại trang đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update account details')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin Tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAccountDetails,
          ),
        ],
      ),
      body: accountDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: false, // Make email field read-only
            ),
            TextFormField(
              controller: _statusController,
              decoration: const InputDecoration(labelText: 'Trạng thái'),
              enabled: false, // Make status field read-only
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true, // Hide password input with asterisks
            ),
          ],
        ),
      ),
    );
  }
}
