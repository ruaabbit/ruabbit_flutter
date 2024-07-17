import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/app/WaterFree/model/water_free_profile.dart';
import '../model/user_profile.dart';
import '../util/persist.dart';
import 'login_page.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  MePageState createState() => MePageState();
}

class MePageState extends State<MePage> {
  late CookieManager cookieManager;
  final cardNumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cookieManager = CookieManager.instance();

    // 使用 WidgetsBinding.instance.addPostFrameCallback 来确保在 initState 完成后访问 Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cardNumController.text =
          Provider.of<WaterFreeProfile>(context, listen: false).cardId;
    });
  }

  @override
  void dispose() {
    cardNumController.dispose();
    super.dispose();
  }

  void _logout() {
    // deleteSavedCookies();
    // deleteIsLogin();
    cookieManager.deleteAllCookies();
    cookieManager.removeSessionCookies();
    PlatformWebStorageManager(const PlatformWebStorageManagerCreationParams())
        .deleteAllData();

    Provider.of<UserProfile>(context, listen: false).isLogin = false;
    Provider.of<UserProfile>(context, listen: false).clearCookies();

    // widget.onLogoutCallback(true);
  }

  void _login(bool result) {
    if (result) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile>(context);
    final waterFreeProfile = Provider.of<WaterFreeProfile>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: Column(
        children: [
          // 显示登录状态
          ListTile(
            title: Text(userProfile.isLogin ? '信息门户已登录' : '信息门户未登录'),
            trailing: userProfile.isLogin
                ? TextButton(
                    onPressed: () {
                      _logout();
                    },
                    child: const Text('退出登录'),
                  )
                : TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage(
                                  onLoginCallback: _login,
                                )),
                      );
                    },
                    child: const Text('登录'),
                  ),
          ),
          const Divider(),
          // 显示WaterFree卡号
          ListTile(
            title: const Text('WaterFree 卡号'),
            subtitle: TextField(
              controller: cardNumController,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Provider.of<WaterFreeProfile>(context, listen: false)
                        .cardId = cardNumController.text;
                  },
                  child: const Text('保存'),
                ),
                const SizedBox(width: 8), // 添加间距
                IconButton(
                  icon: const Icon(Icons.question_mark),
                  onPressed: () {
                    // 弹窗显示两张图片(guide1和guide2)，用于告诉用户如何获取卡号
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('如何获取卡号？'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image.asset(
                                    'assets/images/guide1.jpg',
                                    height: 220,
                                  ),
                                  Image.asset(
                                    'assets/images/guide2.jpg',
                                    height: 220,
                                  ),
                                ],
                              )
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('知道了'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const Divider(),
          // 显示其他数据
          Expanded(
            child: ListView.builder(
              itemCount: userProfile.cookies.length,
              itemBuilder: (context, index) {
                final cookie = userProfile.cookies[index];
                return ListTile(
                  title: Text(cookie.name),
                  subtitle: Text(cookie.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
