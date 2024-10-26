import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test5/screen/product_screen.dart';

import 'account_screen.dart';
import 'favorite_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Widget> _tabs = [
    const ProductScreen(),
    const FavoriteScreen(),
    const AccountScreen(),
  ];

  HomeScreen({super.key});

  Future<bool> _checkLoginStatus(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    int? id = prefs.getInt("accId");
    if (id == null) {
      // If the user is not logged in, navigate to the login screen
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => LoginScreen()),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: 'Favorite'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          if (index == 1) {
            return FutureBuilder<bool>(
              future: _checkLoginStatus(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == true) {
                  return _tabs[index];
                }
                return const SizedBox(); // Empty container if not logged in
              },
            );
          } else {
            return _tabs[index];
          }
        },
      ),
    );
  }
}
