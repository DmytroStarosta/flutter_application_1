import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/repositories/local_device_repository.dart';
import 'package:flutter_application_1/data/services/mqtt_service.dart';
import 'package:flutter_application_1/pages/edit_device.dart';
import 'package:flutter_application_1/widgets/device_button.dart';
import 'package:flutter_application_1/widgets/sensor_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _localRepo = LocalDeviceRepository();
  final _mqttService = MqttService();
  late Future<List<DeviceModel>> _devFuture;
  int _selIdx = 0;

  @override void initState() {
    super.initState();
    _devFuture = _localRepo.getDevices();
  }

  void _refresh() {
    setState(() { _devFuture = _localRepo.getDevices(); });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.account_circle, size: 40),
            onPressed: () => Navigator.pushNamed(context, '/profile'))
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: FutureBuilder<List<DeviceModel>>(
            future: _devFuture,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final devs = snap.data ?? [];
              if (_selIdx >= devs.length && devs.isNotEmpty) _selIdx = 0;
              final dev = devs.isEmpty ? null : devs[_selIdx];

              return Padding(padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Smart meteostation', style: TextStyle(
                      color: Colors.white, fontSize: 32, 
                      fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on, color: Colors.white70),
                      Text(dev?.location ?? 'No devices', style: const 
                        TextStyle(color: Colors.white70, fontSize: 18))
                    ]), const SizedBox(height: 32),
                    Row(children: [
                      const Text('My Devices', style: TextStyle(
                        color: Colors.white, fontSize: 20)), const Spacer(),
                      if (dev != null) IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.white),
                        onPressed: () async {
                          await Navigator.push<void>(context, 
                            MaterialPageRoute<void>(
                              builder: (_) => EditDeviceScreen(device: dev)));
                          _refresh();
                        })
                    ]), const SizedBox(height: 12),
                    SizedBox(height: 40, child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: devs.length + 1,
                      itemBuilder: (c, i) {
                        if (i == devs.length) {
                          return DeviceButton(name: '+ Add', isActive: false,
                            onTap: () async {
                              await Navigator.pushNamed(context, '/add_device');
                              _refresh();
                            });
                        }
                        return DeviceButton(name: devs[i].name, 
                          isActive: _selIdx == i,
                          onTap: () => setState(() => _selIdx = i));
                      })), const SizedBox(height: 32),
                    _buildGrid(dev),
                  ]));
            }),
        ),
      ),
    );
  }

  Widget _buildGrid(DeviceModel? dev) {
    return StreamBuilder<String>(
      stream: _mqttService.sensorStream,
      builder: (ctx, snap) {
        String t = dev?.temperature.toString() ?? '24',
               h = dev?.humidity.toString() ?? '50';
        if (snap.hasData) {
          try {
            final d = jsonDecode(snap.data!) as Map<String, dynamic>;
            t = d['temperature']?.toString() ?? t;
            h = d['humidity']?.toString() ?? h;
          } catch (_) {}
        }
        return Expanded(child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 16, mainAxisSpacing: 16, children: [
            SensorCard(title: 'Temp', value: t, unit: '°C', 
              icon: Icons.thermostat),
            SensorCard(title: 'Hum', value: h, unit: '%', 
              icon: Icons.water_drop),
            const SensorCard(title: 'Press', value: '1013', 
              unit: ' hPa', icon: Icons.speed),
            const SensorCard(title: 'Status', value: 'Online', 
              unit: '', icon: Icons.cloud_done),
          ]));
      });
  }
}
