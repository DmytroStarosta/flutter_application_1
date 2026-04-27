import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/widgets/sensor_card.dart';

class SensorGrid extends StatelessWidget {
  final DeviceModel? dev;
  final Map<String, dynamic> mqttData;

  const SensorGrid({required this.mqttData, super.key, this.dev});

  @override
  Widget build(BuildContext context) {
    String t = dev?.temperature.toString() ?? '--';
    String h = dev?.humidity.toString() ?? '--';

    if (mqttData['id']?.toString() == dev?.id.toString()) {
      t = mqttData['temperature']?.toString() ?? t;
      h = mqttData['humidity']?.toString() ?? h;
    }

    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          SensorCard(title: 'Temp', value: t, unit: '°C', 
          icon: Icons.thermostat),
          SensorCard(title: 'Hum', value: h, unit: '%', icon: Icons.water_drop),
          SensorCard(
            title: 'Press',
            value: dev?.pressure.toString() ?? '1013',
            unit: ' hPa',
            icon: Icons.speed,
          ),
          const SensorCard(
            title: 'Status', value: 'Online', unit: '', icon: Icons.cloud_done,
          ),
        ],
      ),
    );
  }
}
