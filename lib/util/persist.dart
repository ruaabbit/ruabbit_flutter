import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/WaterFree/model/water_free_profile.dart';
import '../model/user_profile.dart';

// isLogin
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

// cookies
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

Future<UserProfile> getUserProfileFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final String? userProfileJsonString = prefs.getString('userProfile');
  if (userProfileJsonString != null) {
    final userProfileJson = jsonDecode(userProfileJsonString);
    return UserProfile.fromJson(userProfileJson);
  } else {
    return UserProfile(cookies: [], isLogin: false);
  }
}

Future<WaterFreeProfile> getWaterFreeProfileFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final String? waterFreeProfileJsonString =
      prefs.getString('waterFreeProfile');
  if (waterFreeProfileJsonString != null) {
    final waterFreeProfileJson = jsonDecode(waterFreeProfileJsonString);
    return WaterFreeProfile.fromJson(waterFreeProfileJson);
  } else {
    return WaterFreeProfile(cardId: '', waterDispenserList: []);
  }
}
