import 'dart:convert';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/repositories/device_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDeviceRepository implements DeviceRepository {
  static const String _storageKey = 'my_devices_list';

  @override
  Future<List<DeviceModel>> getDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);

    if (data == null || data.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;

      return decoded.map((item) {
        return DeviceModel.fromMap(item as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addDevice(DeviceModel device) async {
    final devices = await getDevices();
    devices.add(device);
    await _saveToPrefs(devices);
  }

  @override
  Future<void> updateDevice(DeviceModel updatedDevice) async {
    final devices = await getDevices();
    final index = devices.indexWhere((d) => d.id == updatedDevice.id);
    if (index != -1) {
      devices[index] = updatedDevice;
      await _saveToPrefs(devices);
    }
  }

  @override
  Future<void> deleteDevice(String id) async {
    final devices = await getDevices();
    devices.removeWhere((d) => d.id == id);
    await _saveToPrefs(devices);
  }

  Future<void> _saveToPrefs(List<DeviceModel> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      devices.map((d) => d.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}
