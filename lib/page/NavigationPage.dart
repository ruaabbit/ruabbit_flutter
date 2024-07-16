import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/model/UserProfile.dart';
import 'LoginPage.dart';
import 'MainPage.dart';
import 'MePage.dart';

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
      MePage(
        onLogoutCallback: _handleLogout,
      ),
    ];
  }

  void onItemTapped(int index) {
    bool isLogin = Provider.of<UserProfile>(context, listen: false).isLogin;

    if (index == 1 && !isLogin) {
      // 如果点击个人中心且未登录，打开登录页面
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
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
