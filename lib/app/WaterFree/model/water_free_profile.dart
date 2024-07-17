import 'package:flutter/material.dart';
import 'water_dispenser.dart';

class WaterFreeProfile extends ChangeNotifier {
  String cardId = "";
  List<WaterDispenser> waterDispenserList = [];

  void addWaterDispenser(String machineID, String description) {
    waterDispenserList.add(WaterDispenser(machineID, description));
    notifyListeners();
  }

  void removeWaterDispenser(int index) {
    waterDispenserList.removeAt(index);
    notifyListeners();
  }
}
