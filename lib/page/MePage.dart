import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import '../model/UserProfile.dart';
import '../util/persist.dart';

class MePage extends StatefulWidget {
  final void Function(bool) onLogoutCallback;

  const MePage({super.key, required this.onLogoutCallback});

  @override
  MePageState createState() => MePageState();
}

class MePageState extends State<MePage> {
  late CookieManager cookieManager;

  @override
  void initState() {
    super.initState();
    cookieManager = CookieManager.instance();
  }

  void _logout() {
    deleteSavedCookies();
    deleteIsLogin();
    cookieManager.deleteAllCookies();
    cookieManager.removeSessionCookies();
    PlatformWebStorageManager(const PlatformWebStorageManagerCreationParams())
        .deleteAllData();

    Provider.of<UserProfile>(context, listen: false).isLogin = false;
    Provider.of<UserProfile>(context, listen: false).clearCookies();

    widget.onLogoutCallback(true);
  }

  @override
  Widget build(BuildContext context) {
    final cookies = Provider.of<UserProfile>(context).cookies;

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
              final title = cookie.name;
              final subtitle = cookie.value;
              return ListTile(
                title: Text(title),
                subtitle: Text(subtitle),
              );
            },
          )),
          ElevatedButton(
            onPressed: _logout,
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }
}
