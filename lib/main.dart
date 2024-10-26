import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test5/model/cart.dart';
import 'package:test5/screen/cart_screen.dart';
import 'package:test5/screen/home_screen.dart';
import 'package:test5/screen/login_screen.dart';
import 'package:test5/screen/order_management_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Products App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/login': (context) => LoginScreen(),
        '/order-management': (context) => const OrderManagementScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

