import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../util/toast.dart';

class AESCoder {
  static final key = encrypt_lib.Key.fromBase64('3n4DdO47LWH2Co/WfpbdyA==');

  static String encrypt(String data) {
    final iv = encrypt_lib.IV.fromLength(16);
    final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.ecb));

    final encrypted = encrypter.encrypt(data, iv: iv);
    return base64Encode(encrypted.bytes);
  }

  static String decrypt(String encryptedData) {
    final iv = encrypt_lib.IV.fromLength(16);
    final encrypted = base64Decode(encryptedData);
    final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.ecb));
    final decrypted = encrypter.decrypt64(utf8.decode(encrypted), iv: iv);
    return decrypted;
  }
}

// class Storage {
//   static late SharedPreferences _prefs; // 用于存储数据的实例
//   static List<WaterDispenser> _waterDispensers = [];
//
//   static Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//
//     // final jsonFavorites = jsonDecode(_prefs.getString('favorites') ?? '{}');
//     //
//     // _favorites =
//     //     Map<String, Map<String, String>>.from(jsonFavorites.map((key, value) {
//     //   return MapEntry(key, Map<String, String>.from(value as Map));
//     // }));
//     //
//     // _favoritesNames = _prefs.getStringList('favoritesNames')?.toSet() ?? {};
//
//     final jsonFavoritesNew =
//     jsonDecode(_prefs.getString('favoritesNew') ?? '[]');
//     // 将JSON解析为WaterDispenser数组,为空则创建一个空数组
//     _waterDispensers = (jsonFavoritesNew as List)
//         .map((item) => WaterDispenser.fromJson(item))
//         .toList();
//   }
//
//   // Getters and Setters
//   static String? get cardNum => _prefs.getString('cardNum');
//
//   static set cardNum(String? value) => _prefs.setString('cardNum', value!);
//
//   static List<WaterDispenser> get waterDispensers {
//     return _waterDispensers;
//   }
//
//   static Future<bool> addWaterDispenser(
//       String machineID,
//       String description,
//       ) async {
//     // 判断machineID是否是一个最多5位的数字（仅使用正则表达式）
//     if (!RegExp(r'^\d{1,5}$').hasMatch(machineID)) {
//       return false;
//     }
//
//     // 判断machineID是否已经添加过，否则添加
//     if (_waterDispensers
//         .where((waterDispenser) => waterDispenser.machineID == machineID)
//         .isEmpty) {
//       _waterDispensers.add(
//         WaterDispenser()
//           ..region = 'NULL'
//           ..building = 'NULL'
//           ..floor = 'NULL'
//           ..machineID = machineID
//           ..description = description,
//       );
//       await _prefs.setString('favoritesNew', jsonEncode(_waterDispensers));
//       return true;
//     } else {
//       return false;
//     }
//   }
//
//   static Future<bool> removeWaterDispenser(
//       String machineID,
//       ) async {
//     // 判断machineID是否存在
//     if (_waterDispensers
//         .where((waterDispenser) => waterDispenser.machineID == machineID)
//         .isNotEmpty) {
//       _waterDispensers.removeWhere(
//               (waterDispenser) => waterDispenser.machineID == machineID);
//       await _prefs.setString('favoritesNew', jsonEncode(_waterDispensers));
//       return true;
//     } else {
//       return false;
//     }
//   }
// }

Future<String> getToken(String encrypted) async {
  var resp = await http.get(Uri.parse(
      'http://222.195.158.17:5001/waterapi/api/GetToken?info=$encrypted'));
  if (resp.statusCode == 200) {
    var token = json.decode(resp.body)["Token"];
    if (token != "") {
      return token;
    } else {
      return '';
    }
  } else {
    return '';
  }
}

void waterStart(cardNum, machineNum) {
  var data =
      '{"userid":"$cardNum","userpassword":"kv7XjPzrDNJY0pdZ#","time":"20230804080808"}';

  final encrypted = AESCoder.encrypt(data);

  Future<bool> getWater(token) async {
    if (token != '') {
      var resp = await http.get(Uri.parse(
          'http://222.195.158.17:5001/waterapi/api/ActStartCostNotice?posno=$machineNum&ano=$cardNum&balance=99999&costmoney=100&token=$token'));
      if (resp.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  getToken(encrypted).then((token) {
    getWater(token).then((success) {
      if (success) {
        showToast("开始放水");
      } else {
        showToast("放水失败");
      }
    });
  });
}

void waterStop(cardNum, machineNum) {
  var data =
      '{"userid":"$cardNum","userpassword":"kv7XjPzrDNJY0pdZ#","time":"20230804080808"}';

  final encrypted = AESCoder.encrypt(data);

  Future<bool> getWater(token) async {
    if (token != '') {
      var resp = await http.get(Uri.parse(
          'http://222.195.158.17:5001/waterapi/api/ActOverCostNotice?posno=$machineNum&ano=$cardNum&balance=99999&costmoney=100&token=$token'));
      if (resp.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  getToken(encrypted).then((token) {
    getWater(token).then((success) {
      if (success) {
        showToast("停止放水");
      } else {
        showToast("停水失败");
      }
    });
  });
}
