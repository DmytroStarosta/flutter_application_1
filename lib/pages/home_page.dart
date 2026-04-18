import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/repositories/local_device_repository.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';
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
  final _apiService = ApiService();
  final _connService = ConnectivityService();
  final _mqttService = MqttService();
  late Future<List<DeviceModel>> _devFuture;
  int _selIdx = 0;
  bool _isAuth = true, _authOk = false;

  @override void initState() {
    super.initState();
    _devFuture = _syncDevices();
    _startSession();
  }

  Future<List<DeviceModel>> _syncDevices() async {
    try { return await _apiService.fetchRemoteDevices(); }
    catch (_) { return await _localRepo.getDevices(); }
  }

  Future<void> _startSession() async {
    setState(() => _isAuth = true);
    try {
      await _mqttService.connect();
      final res = await _mqttService.authenticateDevice('key-1');
      if (mounted) setState(() { _authOk = res; _isAuth = false; });
    } catch (e) {
      if (mounted) setState(() => _isAuth = false);
      if (mounted) _showAuthError(e.toString());
    }
  }

  void _showAuthError(String msg) {
    showDialog<void>(context: context, barrierDismissible: false,
      builder: (c) => AlertDialog(title: const Text('Auth Error'),
        content: Text(msg), actions: [
          TextButton(
            onPressed: () { Navigator.pop(c); _startSession(); },
            child: const Text('Retry'))]));
  }

  void _refresh() => setState(() => _devFuture = _syncDevices());

  @override Widget build(BuildContext context) {
    if (_isAuth) {
      return const Scaffold(backgroundColor: Color(0xFF00B8FC),
      body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    if (!_authOk) return const Scaffold(body: Center(child: Text('Denied')));

    return StreamBuilder<List<ConnectivityResult>>(
      stream: _connService.connectivityStream,
      initialData: const [ConnectivityResult.wifi],
      builder: (ctx, snap) {
        final isOff = snap.data?.contains(ConnectivityResult.none) ?? true;
        return Scaffold(extendBodyBehindAppBar: true,
          appBar: AppBar(title: const Text('Home'), elevation: 0,
            backgroundColor: Colors.transparent, actions: [
              IconButton(icon: const Icon(Icons.account_circle, size: 40),
                onPressed: () => Navigator.pushNamed(
                  context, '/profile'))]),
          body: DecoratedBox(
            decoration: const BoxDecoration(gradient: LinearGradient(
              colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SafeArea(child: FutureBuilder<List<DeviceModel>>(
              future: _devFuture,
              builder: (ctx, fSnap) {
                if (fSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator()); }
                final devs = fSnap.data ?? [];
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
                        Text(dev?.location ?? 'No devices',
                          style: const TextStyle(
                            color: Colors.white70, fontSize: 18))
                      ]), const SizedBox(height: 32),
                      Row(children: [
                        const Text('My Devices', style: TextStyle(
                          color: Colors.white, fontSize: 20)), const Spacer(),
                        if (dev != null) IconButton(
                          icon: Icon(Icons.edit_note,
                            color: isOff ? Colors.white24 : Colors.white),
                          onPressed: isOff ? null : () async {
                            await Navigator.push(context,
                              MaterialPageRoute<void>(builder: (_) =>
                                EditDeviceScreen(device: dev)));
                            _refresh(); })]), const SizedBox(height: 12),
                      SizedBox(height: 40, child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: devs.length + 1,
                        itemBuilder: (c, i) {
                          if (i == devs.length) {
                            return DeviceButton(
                            name: '+ Add', isActive: false,
                            onTap: isOff ? null : () async {
                              await Navigator.pushNamed(
                                context, '/add_device');
                              _refresh(); });
                          }
                          return DeviceButton(name: devs[i].name,
                            isActive: _selIdx == i,
                            onTap: () => setState(() => _selIdx = i));
                        })), const SizedBox(height: 32),
                      _buildGrid(dev, isOff)]));
              }))));});
  }

  Widget _buildGrid(DeviceModel? dev, bool isOff) {
    return StreamBuilder<String>(stream: _mqttService.sensorStream,
      builder: (ctx, snap) {
        String temp = dev?.temperature.toString() ?? '--';
        String hum = dev?.humidity.toString() ?? '--';
        if (snap.hasData) {
          try {
            final d = jsonDecode(snap.data!) as Map<String, dynamic>;
            temp = d['temperature']?.toString() ?? temp;
            hum = d['humidity']?.toString() ?? hum;
          } catch (_) {}
        }
        return Expanded(child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          crossAxisSpacing: 16, mainAxisSpacing: 16, children: [
            SensorCard(title: 'Temp', value: temp, unit: '°C',
              icon: Icons.thermostat),
            SensorCard(title: 'Hum', value: hum, unit: '%',
              icon: Icons.water_drop),
            SensorCard(title: 'Press',
              value: dev?.pressure.toString() ?? '--',
              unit: ' hPa', icon: Icons.speed),
            SensorCard(title: 'Status',
              value: dev != null ? (isOff ? 'Off' : 'On') : '--',
              unit: '', icon: isOff ? Icons.cloud_off : Icons.cloud_done)
          ]));});
  }
}
