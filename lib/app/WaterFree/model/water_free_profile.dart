import 'dart:convert';

import 'package:flutter/material.dart';
import 'water_dispenser.dart';

class WaterFreeProfile extends ChangeNotifier {
  String cardId = "";
  List<WaterDispenser> waterDispenserList = [];

  WaterFreeProfile({required this.cardId, required this.waterDispenserList});

  void addWaterDispenser(String machineID, String description) {
    waterDispenserList.add(WaterDispenser(machineID, description));
    notifyListeners();
  }

  void removeWaterDispenser(int index) {
    waterDispenserList.removeAt(index);
    notifyListeners();
  }

  factory WaterFreeProfile.fromJson(Map<String, dynamic> json) {
    return WaterFreeProfile(
      cardId: json['cardId'] as String,
      waterDispenserList: (json['waterDispenserList'] as List)
          .map((item) => WaterDispenser.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'waterDispenserList':
          waterDispenserList.map((item) => item.toJson()).toList(),
    };
  }
}
