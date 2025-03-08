import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/phone_profile.dart';

class OrderService {
  static const String baseUrl = 'https://newmapi.7mate.cn';
  
  Future<Map<String, dynamic>> getCyclingStatus(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/order/cycling'),
        headers: {
          'Host': 'newmapi.7mate.cn',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('请求失败: ${response.body}');
      }
    } catch (e) {
      throw Exception('网络请求错误: $e');
    }
  }

  Future<Map<String, dynamic>> unlockCar(String token, PhoneProfile phoneProfile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/car/unlock'),
        headers: {
          'Host': 'newmapi.7mate.cn',
          'Authorization': token,
          'Content-Type': 'application/x-www-form-urlencoded',
          'Phone-Brand': phoneProfile.phoneBrand,
          'Phone-System': phoneProfile.phoneSystem,
          'Phone-Model': phoneProfile.phoneModel,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('请求失败: ${response.body}');
      }
    } catch (e) {
      throw Exception('网络请求错误: $e');
    }
  }

  Future<Map<String, dynamic>> startDriving(String token, String carNumber, PhoneProfile phoneProfile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/order'),
        headers: {
          'Host': 'newmapi.7mate.cn',
          'Authorization': token,
          'Content-Type': 'application/x-www-form-urlencoded',
          'Phone-Brand': phoneProfile.phoneBrand,
          'Phone-System': phoneProfile.phoneSystem,
          'Phone-Model': phoneProfile.phoneModel,
        },
        body: {
          'longtitude': '',
          'latitude': '',
          'order_type': '1',
          'car_number': carNumber,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('请求失败: ${response.body}');
      }
    } catch (e) {
      throw Exception('网络请求错误: $e');
    }
  }

  Future<Map<String, dynamic>> returnCar(String token, PhoneProfile phoneProfile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/car/lock'),
        headers: {
          'Host': 'newmapi.7mate.cn',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Phone-Brand': phoneProfile.phoneBrand,
          'Phone-System': phoneProfile.phoneSystem,
          'Phone-Model': phoneProfile.phoneModel,
        },
        body: {
          'longtitude': '108.892286',
          'latitude': '34.367498',
          'action_type': '2',
          'back_type': '2',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('请求失败: ${response.body}');
      }
    } catch (e) {
      throw Exception('网络请求错误: $e');
    }
  }
} 