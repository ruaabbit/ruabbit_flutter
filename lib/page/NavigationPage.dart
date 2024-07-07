import 'package:flutter/material.dart';
import '../util/persist.dart';
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
  bool _isLoggedIn = false; // 添加登录状态

  // 更新页面列表
  late final List<Widget> _pages;

  void _handleLogout(bool isLoggedIn) {
    deleteIsLogin();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _selectedIndex = 0;
    });
  }

  void _handleLogin(bool isLoggedIn) {
    saveIsLogin();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _selectedIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    getIsLogin().then((value) {
      _isLoggedIn = value;
    });
    _pages = [
      const MainPage(), // 替换为您的主页
      MePage(onLogoutCallback: _handleLogout),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 1 && !_isLoggedIn) {
      // 如果点击个人中心且未登录，打开登录页面
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(
                  onLoginCallback: _handleLogin,
                )),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
