class WaterDispenser {
  final String machineID; // 机器号
  final String description; // 机器描述

  WaterDispenser(this.machineID, this.description);

  factory WaterDispenser.fromJson(Map<String, dynamic> json) {
    return WaterDispenser(
      json['machineID'] as String,
      json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machineID': machineID,
      'description': description,
    };
  }
}
