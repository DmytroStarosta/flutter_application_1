import 'package:dio/dio.dart';
import 'package:flutter_application_1/data/models/device_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://my-iot-api.com'));

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          const String token = 'my-super-secret-jwt-token-123';
          
          options.headers['Authorization'] = 'Bearer $token';
          
          return handler.next(options);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      return {
        'fullName': 'Dmytro Polytech',
        'email': 'dmytro.student@lpnu.ua',
      };
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<List<DeviceModel>> fetchRemoteDevices() async {
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      return [
        const DeviceModel(
          id: '1',
          name: 'ESP32 Main',
          location: 'Lviv Lab',
          temperature: 22.5,
          humidity: 45,
          pressure: 1013.2,
        ),
      ];
    } catch (e) {
      throw Exception('Server error: $e');
    }
  }
}
