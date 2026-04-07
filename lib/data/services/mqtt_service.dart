import 'dart:async';
import 'dart:io';
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

  Future<void> connect() async {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }

    final String clientId =
        'flutter_weather_${DateTime.now().millisecondsSinceEpoch}';

    client = MqttServerClient('broker.hivemq.com', clientId);
    client!.port = 1883;
    client!.keepAlivePeriod = 20;
    client!.logging(on: false);

    client!.onDisconnected = () => debugPrint('MQTT: Disconnected');
    client!.onConnected = () => debugPrint('MQTT: Connected to HiveMQ');
    client!.onSubscribed = (topic) => debugPrint('MQTT: Subscribed to $topic');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect().timeout(const Duration(seconds: 5));
    } on SocketException catch (e) {
      debugPrint('MQTT Socket Error: ${e.message}');
      _cleanup();
      return;
    } on TimeoutException {
      debugPrint('MQTT Connection Timeout');
      _cleanup();
      return;
    } catch (e) {
      debugPrint('MQTT Error: $e');
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
        },
        onError: (Object error) => debugPrint('MQTT Stream Error: $error'),
        cancelOnError: false,
      );
    }
  }

  void _cleanup() {
    client?.disconnect();
    debugPrint('MQTT: Cleanup performed after failed connection.');
  }

  void disconnect() {
    client?.disconnect();
  }
}
