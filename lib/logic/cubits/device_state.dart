import 'package:flutter_application_1/data/models/device_model.dart';

class DeviceState {
  final List<DeviceModel> devices;
  final int selectedIdx;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> mqttData;

  const DeviceState({
    this.devices = const [],
    this.selectedIdx = 0,
    this.isLoading = false,
    this.error,
    this.mqttData = const {},
  });

  DeviceState copyWith({
    List<DeviceModel>? devices,
    int? selectedIdx,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? mqttData,
  }) {
    return DeviceState(
      devices: devices ?? this.devices,
      selectedIdx: selectedIdx ?? this.selectedIdx,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      mqttData: mqttData ?? this.mqttData,
    );
  }
}
