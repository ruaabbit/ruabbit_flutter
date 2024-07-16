import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class UserProfile extends ChangeNotifier {
  late List<Cookie> cookies = [];
  late bool isLogin = false;

  void clearCookies() {
    cookies.clear();
    notifyListeners();
  }
}
