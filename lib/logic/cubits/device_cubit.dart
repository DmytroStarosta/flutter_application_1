import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeviceState {}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<DeviceModel> devices;
  DeviceLoaded(this.devices);
}

class DeviceError extends DeviceState {
  final String message;
  DeviceError(this.message);
}

class DeviceCubit extends Cubit<DeviceState> {
  final ApiService _api = ApiService();

  DeviceCubit() : super(DeviceInitial());

  Future<void> loadDevices() async {
    try {
      emit(DeviceLoading());
      final devices = await _api.fetchRemoteDevices();
      emit(DeviceLoaded(devices));
    } catch (e) {
      emit(DeviceError('Failed to fetch devices: ${e.toString()}'));
    }
  }

  Future<void> removeDevice(String id) async {
    try {
      await _api.deleteDevice(id);
      await loadDevices();
    } catch (e) {
      emit(DeviceError('Failed to delete device: $id'));
    }
  }
}
