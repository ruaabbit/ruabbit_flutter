import 'package:flutter/material.dart';

class PhoneProfile extends ChangeNotifier {
  String _phoneBrand = 'iPhone';
  String _phoneSystem = 'iOS';
  String _phoneModel = 'iPhone 13<iPhone14,5>';

  String get phoneBrand => _phoneBrand;
  String get phoneSystem => _phoneSystem;
  String get phoneModel => _phoneModel;

  set phoneBrand(String value) {
    _phoneBrand = value;
    notifyListeners();
  }

  set phoneSystem(String value) {
    _phoneSystem = value;
    notifyListeners();
  }

  set phoneModel(String value) {
    _phoneModel = value;
    notifyListeners();
  }

  PhoneProfile({
    required String phoneBrand,
    required String phoneSystem,
    required String phoneModel,
  }) : _phoneBrand = phoneBrand,
       _phoneSystem = phoneSystem,
       _phoneModel = phoneModel;

  factory PhoneProfile.fromJson(Map<String, dynamic> json) {
    return PhoneProfile(
      phoneBrand: json['phoneBrand'] as String,
      phoneSystem: json['phoneSystem'] as String,
      phoneModel: json['phoneModel'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneBrand': _phoneBrand,
      'phoneSystem': _phoneSystem,
      'phoneModel': _phoneModel,
    };
  }
} 