import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? client;
  final _dataController = StreamController<String>.broadcast();
  Stream<String> get sensorStream => _dataController.stream;
  
  final ApiService _api = ApiService();

  void publish(String topic, String message) {
    final bool isConnected =
        client?.connectionStatus?.state == MqttConnectionState.connected;

    if (isConnected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client!.publishMessage(
        topic,
        MqttQos.atMostOnce,
        builder.payload!,
      );
    }
  }

  Future<void> connect() async {
    final bool isConnected =
        client?.connectionStatus?.state == MqttConnectionState.connected;
    if (isConnected) return;

    final String timeId = DateTime.now().millisecondsSinceEpoch.toString();
    final String clientId = 'flutter_weather_$timeId';

    client = MqttServerClient('broker.hivemq.com', clientId);
    client!.port = 1883;
    client!.keepAlivePeriod = 20;
    client!.autoReconnect = true;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
    } catch (e) {
      _cleanup();
      return;
    }

    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      client!.subscribe('weather/data', MqttQos.atMostOnce);

      client!.updates!.listen(
        (List<MqttReceivedMessage<MqttMessage>> messages) {
          final recMess = messages[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );

          _dataController.add(payload);

          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            
            _api.sendToFirebase({
              'temperature': data['temperature'],
              'humidity': data['humidity'],
              'id': data['id'],
              'cloud_sync': DateTime.now().toIso8601String(),
            });
          } catch (e) {
            debugPrint('Firebase forwarding error: $e');
          }
        },
      );
    }
  }

  Future<bool> authenticateDevice(String token) async {
    return true; 
  }

  void _cleanup() => client?.disconnect();
  void disconnect() => client?.disconnect();
}
