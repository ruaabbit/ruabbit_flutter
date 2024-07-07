import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> getIsLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final bool? isLogin = prefs.getBool('isLogin');
  if (isLogin != null) {
    return isLogin;
  } else {
    return false;
  }
}

Future<bool> deleteIsLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final bool? isLogin = prefs.getBool('isLogin');
  if (isLogin != null) {
    prefs.remove('isLogin');
    return true;
  } else {
    return false;
  }
}

Future<bool> saveIsLogin() async {
  final prefs = await SharedPreferences.getInstance();
  final bool? isLogin = prefs.getBool('isLogin');
  if (isLogin == null) {
    prefs.setBool('isLogin', true);
    return true;
  } else {
    return false;
  }
}

Future<void> saveCookies(List<Cookie> cookies) async {
  final prefs = await SharedPreferences.getInstance();
  final cookieList = cookies.map((cookie) => cookie.toJson()).toList();
  await prefs.setString('cookies', jsonEncode(cookieList));
}

Future<List<Cookie?>> getSavedCookies() async {
  final prefs = await SharedPreferences.getInstance();
  final String? cookieString = prefs.getString('cookies');
  if (cookieString != null) {
    final List cookieList = jsonDecode(cookieString);
    return cookieList.map((cookieMap) => Cookie.fromMap(cookieMap)).toList();
  }
  return [];
}

Future<bool> deleteSavedCookies() async {
  final prefs = await SharedPreferences.getInstance();
  final String? cookieString = prefs.getString('cookies');
  if (cookieString != null) {
    return prefs.remove('cookies');
  }
  return false;
}
