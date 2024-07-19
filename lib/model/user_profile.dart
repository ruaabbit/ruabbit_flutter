import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class UserProfile extends ChangeNotifier {
  late List<Cookie?> cookies = [];
  late bool isLogin = false;

  UserProfile({required this.cookies, required this.isLogin});

  void clearCookies() {
    cookies.clear();
    notifyListeners();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      cookies: (json['cookies'] as List)
          .map((cookieJson) => Cookie.fromMap(cookieJson))
          .toList(),
      isLogin: json['isLogin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookies': cookies.map((cookie) => cookie?.toMap()).toList(),
      'isLogin': isLogin,
    };
  }
}
