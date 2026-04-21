import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/device_model.dart';

class ApiService {
  static const String _url = 'https://69e39c803327837a15535926.mockapi.io';
  final Dio _dio = Dio(BaseOptions(baseUrl: _url));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer key-vlad-35';
        return handler.next(options);
      },
    ));
  }

  Future<void> sendToFirebase(Map<String, dynamic> data) async {
    try {
      const String fireUrl = 
          'https://smart-meteostation-flutter-default-rtdb.europe-west1.firebasedatabase.app/telemetry.json';
      
      final cleanDio = Dio(); 
      
      await cleanDio.put<dynamic>(
        fireUrl, 
        data: data,
      );
      
      debugPrint('>>> Firebase: OK!');
    } catch (e) {
      debugPrint('>>> Firebase Error: $e');
    }
  }

  Future<void> registerUser(Map<String, dynamic> userData) async {
    await _dio.post<dynamic>('/users', data: userData);
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final resp = await _dio.get<dynamic>('/users');
      final List<dynamic> users = resp.data as List<dynamic>;
      for (var u in users) {
        if (u['email'] == email && u['password'] == password) {
          return u as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final resp = await _dio.get<dynamic>('/users/1');
      return resp.data as Map<String, dynamic>;
    } catch (e) {
      return {
        'fullName': 'Vladyslav Student',
        'email': 'vladyslav@lpnu.ua',
      };
    }
  }

  Future<List<DeviceModel>> fetchRemoteDevices() async {
    final resp = await _dio.get<dynamic>('/devices');
    final list = resp.data as List<dynamic>;
    return list.map((e) => 
        DeviceModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addDevice(DeviceModel device) async {
    await _dio.post<dynamic>('/devices', data: device.toMap());
  }

  Future<void> updateDevice(DeviceModel device) async {
    final path = '/devices/${device.id}';
    await _dio.put<dynamic>(path, data: device.toMap());
  }

  Future<void> deleteDevice(String id) async {
    await _dio.delete<dynamic>('/devices/$id');
  }
}
