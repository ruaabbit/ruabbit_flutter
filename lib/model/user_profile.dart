import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class UserProfile extends ChangeNotifier {
  late List<Cookie?> cookies = [];
  late bool isLogin = false;
  String token = '';

  UserProfile({required this.cookies, required this.isLogin, required this.token});

  void clearCookies() {
    cookies.clear();
    notifyListeners();
  }

  void setToken(String newToken) {
    token = newToken;
    notifyListeners();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      cookies: (json['cookies'] as List?)
          ?.map((cookieJson) => Cookie.fromMap(cookieJson))
          .toList() ?? [],
      isLogin: json['isLogin'] as bool? ?? false,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cookies': cookies.map((cookie) => cookie?.toMap()).toList(),
      'isLogin': isLogin,
      'token': token,
    };
  }
}
