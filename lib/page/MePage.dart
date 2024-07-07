import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../util/persist.dart';

class MePage extends StatefulWidget {
  final Function(bool) onLogoutCallback;

  const MePage({super.key, required this.onLogoutCallback});

  @override
  MePageState createState() => MePageState();
}

class MePageState extends State<MePage> {
  List<Cookie?> cookies = [];
  CookieManager cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();

    getSavedCookies().then((cookies) {
      this.cookies = cookies;
    });
  }

  Future<void> _logout() async {
    await deleteSavedCookies();
    await deleteIsLogin();
    await cookieManager.deleteAllCookies();
    await cookieManager.removeSessionCookies();
    await PlatformWebStorageManager(
            const PlatformWebStorageManagerCreationParams())
        .deleteAllData();
    setState(() {
      cookies = [];
    });

    widget.onLogoutCallback(false);
    // 可以在这里添加导航到登录页面的逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cookies.length,
              itemBuilder: (context, index) {
                final cookie = cookies[index];
                return ListTile(
                  title: Text(cookie!.name),
                  subtitle: Text(cookie.value),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _logout,
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }
}
