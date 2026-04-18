import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/repositories/local_device_repository.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
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
  final _api = ApiService();
  final _mqtt = MqttService();
  late Future<List<DeviceModel>> _devFuture;
  int _selIdx = 0;

  @override void initState() {
    super.initState();
    _mqtt.connect();
    _devFuture = _sync();
  }

  Future<List<DeviceModel>> _sync() async {
    try {
      final remote = await _api.fetchRemoteDevices();
      for (var d in remote) { await _localRepo.addDevice(d); }
      return remote;
    } catch (e) {
      return await _localRepo.getDevices();
    }
  }

  void _refresh() => setState(() { _devFuture = _sync(); });

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
        child: SafeArea(child: FutureBuilder<List<DeviceModel>>(
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
                  _buildLocationInfo(dev), const SizedBox(height: 32),
                  _buildHeader(dev), const SizedBox(height: 12),
                  _buildList(devs), const SizedBox(height: 32),
                  _buildGrid(dev),
                ]));
          })),
      ),
    );
  }

  Widget _buildLocationInfo(DeviceModel? dev) => Row(children: [
    const Icon(Icons.location_on, color: Colors.white70),
    Text(dev?.location ?? 'No devices', style: const 
      TextStyle(color: Colors.white70, fontSize: 18))
  ]);

  Widget _buildHeader(DeviceModel? dev) => Row(children: [
    const Text('My Devices', style: TextStyle(color: Colors.white, 
    fontSize: 20)),
    const Spacer(),
    if (dev != null) IconButton(
      icon: const Icon(Icons.edit_note, color: Colors.white),
      onPressed: () async {
        await Navigator.push<void>(context, MaterialPageRoute<void>(
          builder: (_) => EditDeviceScreen(device: dev)));
        _refresh();
      })
  ]);

  Widget _buildList(List<DeviceModel> devs) => SizedBox(height: 40, 
    child: ListView.builder(scrollDirection: Axis.horizontal,
      itemCount: devs.length + 1, itemBuilder: (c, i) {
        if (i == devs.length) {
          return DeviceButton(name: '+ Add', isActive: false,
            onTap: () async {
              await Navigator.pushNamed(context, '/add_device');
              _refresh();
            });
        }
        return DeviceButton(name: devs[i].name, isActive: _selIdx == i,
          onTap: () => setState(() => _selIdx = i));
      }));

  Widget _buildGrid(DeviceModel? dev) => StreamBuilder<String>(
    stream: _mqtt.sensorStream, builder: (ctx, snap) {
      String t = dev?.temperature.toString() ?? '--';
      String h = dev?.humidity.toString() ?? '--';

      if (snap.hasData) {
        debugPrint('>>> MQTT RECEIVED: ${snap.data}');
        try {
          final data = jsonDecode(snap.data!) as Map<String, dynamic>;
          final mqttId = data['id']?.toString();
          final currentId = dev?.id.toString();
          
          debugPrint('>>> COMPARE ID: MQTT($mqttId) vs UI($currentId)');

          if (mqttId == currentId) {
            t = data['temperature']?.toString() ?? t;
            h = data['humidity']?.toString() ?? h;
            debugPrint('>>> MATCH! Updating UI: Temp=$t, Hum=$h');
          } else {
            debugPrint('>>> NO MATCH: ID mismatch or missing ID field');
          }
        } catch (e) {
          debugPrint('>>> PARSE ERROR: $e');
        }
      }

      return Expanded(child: GridView.count(crossAxisCount: 2,
        crossAxisSpacing: 16, mainAxisSpacing: 16, children: [
          SensorCard(title: 'Temp', value: t, unit: '°C', 
          icon: Icons.thermostat),
          SensorCard(title: 'Hum', value: h, unit: '%', icon: Icons.water_drop),
          SensorCard(title: 'Press', value: dev?.pressure.toString() ?? '1013', 
              unit: ' hPa', icon: Icons.speed),
          const SensorCard(title: 'Status', value: 'Online', unit: '', 
            icon: Icons.cloud_done),
        ]));
    });
}
