import 'package:flutter_application_1/data/models/device_model.dart';

abstract class DeviceRepository {
  Future<List<DeviceModel>> getDevices();
  Future<void> addDevice(DeviceModel device);
  Future<void> updateDevice(DeviceModel device);
  Future<void> deleteDevice(String id);
}
