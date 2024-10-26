import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/model/account.dart';
import 'package:test5/model/api.dart';
import 'package:test5/screen/registration_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final String uri = "${url.api}/api/login";
  final _keys = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: SingleChildScrollView(
          child: Form(
            key: _keys,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Image.asset('assets/images/account.jpg', width: 200),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    labelText: 'Tên đăng nhập',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập tên đăng nhập';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _passwordController,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        String email = _emailController.text;
                        String password = _passwordController.text;
                        Map<String, String> user = {
                          "email": email,
                          "password": password
                        };
                        Map<String, String> headers = <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        };
                        if (_keys.currentState!.validate()) {
                          http
                              .post(Uri.parse(uri),
                                  headers: headers, body: jsonEncode(user))
                              .then((response) async {
                            var data = jsonDecode(const Utf8Decoder()
                                .convert(response.bodyBytes));
                            if (data['error'] != null) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Thông báo lỗi'),
                                      content: Text(data['error']),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Đóng'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              var acc = Account.fromJson(data['result']);
                              var prefs = await SharedPreferences.getInstance();
                              prefs.setString("fullName", acc.name);
                              prefs.setInt("accId", acc.id);
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()),
                                (Route<dynamic> route) => false,
                              );
                            }
                          });
                        }
                      },
                      child: const Text('Đăng nhập'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text('Đăng ký'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
