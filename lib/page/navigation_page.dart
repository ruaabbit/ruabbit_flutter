import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/model/user_profile.dart';
import 'login_page.dart';
import 'main_page.dart';
import 'me_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  NavigationPageState createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  // 更新页面列表
  late final List<Widget> _pages;

  void _handleLogout(bool result) {
    debugPrint(result.toString());
    setState(() {
      _selectedIndex = 0;
    });
  }

  void _handleLogin(bool result) {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const MainPage(), // 替换为您的主页
      const MePage(),
    ];
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '个人中心',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
