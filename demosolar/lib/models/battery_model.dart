// lib/models/battery_model.dart
// Simple data model to represent battery information coming from Firebase Realtime Database.

class BatteryModel {
  final double batteryVoltage;
  final double batteryCurrent;
  final int batteryPercentage;
  final int batteryLifecycle;
  final double batteryTemperature;

  BatteryModel({
    required this.batteryVoltage,
    required this.batteryCurrent,
    required this.batteryPercentage,
    required this.batteryLifecycle,
    required this.batteryTemperature,
  });

  // Factory constructor to create BatteryModel from a Map (Firebase snapshot data).
  factory BatteryModel.fromMap(Map<dynamic, dynamic> data) {
    return BatteryModel(
      batteryVoltage:
      (data['batteryVoltage'] ?? 0).toDouble(), // Ensure double conversion.
      batteryCurrent:
      (data['batteryCurrent'] ?? 0).toDouble(), // Ensure double conversion.
      batteryPercentage: (data['batteryPercentage'] ?? 0).toInt(),
      batteryLifecycle: (data['batteryLifecycle'] ?? 0).toInt(),
      batteryTemperature:
      (data['batteryTemperature'] ?? 0).toDouble(), // Ensure double conversion.
    );
  }
}
