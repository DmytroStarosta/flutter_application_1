import 'dart:async';
import 'dart:convert';
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

  Future<bool> authenticateDevice(String token) async {
    final bool isConnected =
        client?.connectionStatus?.state == MqttConnectionState.connected;

    if (!isConnected) {
      throw Exception('Network connection is missing');
    }

    final completer = Completer<bool>();

    client!.subscribe('weather/auth/status', MqttQos.atMostOnce);

    final listener = client!.updates!.listen((messages) {
      final MqttPublishMessage recMess =
          messages[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      if (messages[0].topic == 'weather/auth/status') {
        try {
          final data = jsonDecode(payload);
          if (data['status'] == 'authorized') {
            if (!completer.isCompleted) completer.complete(true);
          } else {
            if (!completer.isCompleted) completer.complete(false);
          }
        } catch (e) {
          debugPrint('Auth parse error: $e');
        }
      }
    });

    publish('weather/auth', jsonEncode({'token': token}));

    try {
      final result = await completer.future.timeout(
        const Duration(seconds: 7),
      );
      await listener.cancel();
      return result;
    } on TimeoutException {
      await listener.cancel();
      throw Exception('Device timeout. Check your key or connection.');
    } catch (e) {
      await listener.cancel();
      rethrow;
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
    client!.autoReconnect = true;

    client!.onDisconnected = () => debugPrint('MQTT: Disconnected');
    client!.onConnected = () => debugPrint('MQTT: Connected');

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client!.connectionMessage = connMessage;

    try {
      await client!.connect();
      debugPrint('MQTT: Connection attempt finished');
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
