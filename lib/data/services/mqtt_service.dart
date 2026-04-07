import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? client;
  final _dataController = StreamController<String>.broadcast();
  Stream<String> get sensorStream => _dataController.stream;

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
      debugPrint('MQTT: Published to $topic');
    } else {
      debugPrint('MQTT: Cannot publish, not connected');
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
    client!.logging(on: false);

    client!.onDisconnected = () => debugPrint('MQTT: Disconnected');
    client!.onConnected = () => debugPrint('MQTT: Connected');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('MQTT error: $e');
      _cleanup();
      return;
    }

    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      client!.subscribe('weather/data', MqttQos.atMostOnce);
      client!.subscribe('weather/config', MqttQos.atMostOnce);

      client!.updates!.listen(
        (List<MqttReceivedMessage<MqttMessage>> messages) {
          final recMess = messages[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          _dataController.add(payload);
        },
        onError: (Object err) => debugPrint('MQTT Stream Error: $err'),
      );
    }
  }

  void _cleanup() => client?.disconnect();
  void disconnect() => client?.disconnect();
}
