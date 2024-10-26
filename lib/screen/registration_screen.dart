import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test5/model/api.dart';

class RegistrationScreen extends StatelessWidget {
  final String uri = "${url.api}/api/register";
  final _keys = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController(); // Controller for name
  final TextEditingController _emailController =
      TextEditingController(); // Controller for email
  final TextEditingController _passwordController =
      TextEditingController(); // Controller for password
  final TextEditingController _phoneController =
      TextEditingController(); // Controller for phone
  final TextEditingController _addressController =
      TextEditingController();

  RegistrationScreen({super.key}); // Controller for address

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _keys,
          child: SingleChildScrollView(
            // Wrap in SingleChildScrollView to avoid overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/account.jpg', width: 200),
                TextFormField(
                  controller: _nameController, // Name field
                  decoration: const InputDecoration(
                    hintText: 'Tên người dùng',
                    labelText: 'Tên người dùng',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập tên người dùng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _emailController, // Email field
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập tên email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController, // Password field
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Mật khẩu',
                    labelText: 'Mật khẩu',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _phoneController, // Phone field
                  decoration: const InputDecoration(
                    hintText: 'Số điện thoại',
                    labelText: 'Số điện thoại',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập số điện thoại';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _addressController, // Address field
                  decoration: const InputDecoration(
                    hintText: 'Địa chỉ',
                    labelText: 'Địa chỉ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập địa chỉ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    if (_keys.currentState!.validate()) {
                      String username = _nameController.text;
                      String email = _emailController.text;
                      String password = _passwordController.text;
                      String phone = _phoneController.text;
                      String address = _addressController.text;

                      Map<String, dynamic> user = {
                        "name": username,
                        "email": email,
                        "password": password,
                        "phone": phone,
                        "address": address,
                      };

                      Map<String, String> headers = <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      };

                      http
                          .post(Uri.parse(uri),
                              headers: headers, body: jsonEncode(user))
                          .then((response) {
                        // Handle response
                        if (response.statusCode == 200) {
                          // Registration successful, handle success
                          Navigator.pop(context);
                        } else {
                          // Registration failed, show error
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đăng ký không thành công')),
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Đăng ký'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
