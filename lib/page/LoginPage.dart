import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:ruabbit_flutter/model/UserProfile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  InAppWebViewController? webViewController;
  double progress = 0;
  String title = '信息门户登录';
  CookieManager cookieManager = CookieManager.instance();
  bool webViewVisible = true;

  @override
  void dispose() {
    webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: webViewVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            onEnd: () {
              if (!webViewVisible) {
                Navigator.of(context).pop();
              }
            },
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(saveFormData: false),
              initialUrlRequest: URLRequest(
                  url: WebUri.uri(Uri.parse("https://my.ouc.edu.cn/"))),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                if (mounted) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                }
              },
              onTitleChanged: (controller, title) {
                if (mounted) {
                  setState(() {
                    this.title = title!;
                  });
                }
              },
              onPageCommitVisible: (controller, url) {
                if (url.toString() == 'https://my.ouc.edu.cn/#/home') {
                  cookieManager
                      .getCookies(url: WebUri('https://my.ouc.edu.cn/'))
                      .then((cookies) {
                    debugPrint(cookies.toString());
                    Provider.of<UserProfile>(context, listen: false).cookies =
                        cookies;
                  });
                  Provider.of<UserProfile>(context, listen: false).isLogin =
                      true;

                  setState(() {
                    webViewVisible = false;
                  });
                }
              },
            ),
          ),
          progress < 1.0
              ? Stack(children: [
                  LinearProgressIndicator(value: progress),
                  Container(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                ])
              : Container(),
        ],
      ),
    );
  }
}
