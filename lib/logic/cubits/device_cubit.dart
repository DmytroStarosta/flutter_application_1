import 'dart:async';
import 'dart:convert';

import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:flutter_application_1/data/services/mqtt_service.dart';
import 'package:flutter_application_1/logic/cubits/device_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeviceCubit extends Cubit<DeviceState> {
  final ApiService _api = ApiService();
  final MqttService _mqtt = MqttService();
  StreamSubscription<String>? _mqttSub;

  DeviceCubit() : super(const DeviceState()) {
    _initMqtt();
  }

  void _initMqtt() {
    _mqtt.connect();
    _mqttSub = _mqtt.sensorStream.listen((data) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        emit(state.copyWith(mqttData: decoded));
      } catch (_) {}
    });
  }

  Future<void> loadDevices() async {
    emit(state.copyWith(isLoading: true));
    try {
      final devices = await _api.fetchRemoteDevices();
      emit(state.copyWith(devices: devices, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void selectDevice(int index) => emit(state.copyWith(selectedIdx: index));

  Future<void> createDevice(String name, String location) async {
    emit(state.copyWith(isLoading: true));
    try {
      final newDev = DeviceModel(id: '', name: name, location: location);
      await _api.addDevice(newDev);
      await loadDevices();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Failed to add device'));
    }
  }

  Future<void> editDevice(DeviceModel updated) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _api.updateDevice(updated);
      final mqttMsg = jsonEncode({
        'name': updated.name,
        'location': updated.location,
      });
      _mqtt.publish('weather/config', mqttMsg);
      await loadDevices();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Update failed'));
    }
  }

  Future<void> removeDevice(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _api.deleteDevice(id);
      
      final updatedList = await _api.fetchRemoteDevices();

      int newIdx = state.selectedIdx;
      if (newIdx >= updatedList.length) {
        newIdx = updatedList.isEmpty ? 0 : updatedList.length - 1;
      }

      emit(state.copyWith(
        devices: updatedList,
        isLoading: false,
        selectedIdx: newIdx,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _mqttSub?.cancel();
    return super.close();
  }
}
