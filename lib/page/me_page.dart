import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/app/WaterFree/model/water_free_profile.dart';
import 'package:ruabbit_flutter/app/Order/model/phone_profile.dart';
import '../model/user_profile.dart';
import '../util/persist.dart';
import 'login_page.dart';
import 'package:ruabbit_flutter/app/Order/service/order_service.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  MePageState createState() => MePageState();
}

class MePageState extends State<MePage> {
  late CookieManager cookieManager;
  final cardNumController = TextEditingController();
  final sevenMATokenController = TextEditingController();
  final phoneBrandController = TextEditingController();
  final phoneSystemController = TextEditingController();
  final phoneModelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cookieManager = CookieManager.instance();

    // 使用 WidgetsBinding.instance.addPostFrameCallback 来确保在 initState 完成后访问 Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cardNumController.text =
          Provider.of<WaterFreeProfile>(context, listen: false).cardId;
      sevenMATokenController.text =
          Provider.of<UserProfile>(context, listen: false).token;
      final phoneProfile = Provider.of<PhoneProfile>(context, listen: false);
      phoneBrandController.text = phoneProfile.phoneBrand;
      phoneSystemController.text = phoneProfile.phoneSystem;
      phoneModelController.text = phoneProfile.phoneModel;
    });
  }

  @override
  void dispose() {
    cardNumController.dispose();
    sevenMATokenController.dispose();
    phoneBrandController.dispose();
    phoneSystemController.dispose();
    phoneModelController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    cookieManager.deleteAllCookies();
    cookieManager.removeSessionCookies();
    PlatformWebStorageManager(const PlatformWebStorageManagerCreationParams())
        .deleteAllData();

    final userProfile = Provider.of<UserProfile>(context, listen: false);
    userProfile.isLogin = false;
    userProfile.clearCookies();

    await saveUserProfileToPrefs(userProfile);
  }

  void _login(bool result) {
    if (result) {
      setState(() {});
    }
  }

  Future<void> _saveCardNumber() async {
    final cardId = cardNumController.text;
    await editWaterFreeProfileInPrefs({
      'cardId': cardId,
    });

    if (mounted) {
      // 更新Provider中的cardId
      Provider.of<WaterFreeProfile>(context, listen: false).cardId = cardId;

      // 显示保存成功的提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('卡号已保存')),
      );
    }
  }

  Future<void> _saveSevenMAToken() async {
    final token = sevenMATokenController.text;
    
    await editUserProfileInPrefs({
      'token': token,
    });

    if (mounted) {
      // 更新Provider中的token
      Provider.of<UserProfile>(context, listen: false).token = token;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('7MA Token已保存')),
      );
    }
  }

  Future<void> _savePhoneInfo() async {
    await editPhoneProfileInPrefs({
      'phoneBrand': phoneBrandController.text,
      'phoneSystem': phoneSystemController.text,
      'phoneModel': phoneModelController.text,
    });

    if (mounted) {
      // 更新Provider中的手机信息
      final phoneProfile = Provider.of<PhoneProfile>(context, listen: false);
      phoneProfile.phoneBrand = phoneBrandController.text;
      phoneProfile.phoneSystem = phoneSystemController.text;
      phoneProfile.phoneModel = phoneModelController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('手机信息已保存')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile>(context);

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
                    _saveCardNumber();
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
          ListTile(
            title: const Text('7MA Header设置'),
            subtitle: Column(
              children: [
                TextField(
                  controller: phoneBrandController,
                  decoration: const InputDecoration(
                    labelText: 'Phone-Brand',
                    border: UnderlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: phoneSystemController,
                  decoration: const InputDecoration(
                    labelText: 'Phone-System',
                    border: UnderlineInputBorder(),
                  ),
                ),
                TextField(
                  controller: phoneModelController,
                  decoration: const InputDecoration(
                    labelText: 'Phone-Model',
                    border: UnderlineInputBorder(),
                  ),
                ),
              ],
            ),
            trailing: TextButton(
              onPressed: _savePhoneInfo,
              child: const Text('保存'),
            ),
          ),
          const Divider(),
          // 显示7MA Token
          ListTile(
            title: const Text('7MA 乘车Token'),
            subtitle: TextField(
              controller: sevenMATokenController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入7MA乘车Token',
                border: UnderlineInputBorder(),
              ),
            ),
            trailing: TextButton(
              onPressed: () {
                _saveSevenMAToken();
              },
              child: const Text('保存'),
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
                  title: Text(cookie!.name),
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
