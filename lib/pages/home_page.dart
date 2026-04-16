import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/repositories/device_repository.dart';
import 'package:flutter_application_1/data/repositories/local_device_repository.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';
import 'package:flutter_application_1/data/services/mqtt_service.dart';
import 'package:flutter_application_1/pages/edit_device.dart';
import 'package:flutter_application_1/widgets/device_button.dart';
import 'package:flutter_application_1/widgets/sensor_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeviceRepository _deviceRepository = LocalDeviceRepository();
  final ConnectivityService _connectivityService = ConnectivityService();
  final MqttService _mqttService = MqttService();

  List<DeviceModel> _devices = [];
  int _selectedIndex = 0;
  bool _isAuthorizing = true;
  bool _authSuccess = false;

  @override
  void initState() {
    super.initState();
    _refreshDevices();
    _startSession();
  }

  Future<void> _startSession() async {
    setState(() => _isAuthorizing = true);
    try {
      await _mqttService.connect();
      const String token = 'key-1';
      final bool result = await _mqttService.authenticateDevice(token);
      
      if (mounted) {
        setState(() {
          _authSuccess = result;
          _isAuthorizing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthorizing = false);
        _showAuthError(e.toString());
      }
    }
  }

  void _showAuthError(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startSession();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDevices() async {
    final devices = await _deviceRepository.getDevices();
    if (!mounted) return;
    setState(() {
      _devices = devices;
      if (_selectedIndex >= _devices.length && _devices.isNotEmpty) {
        _selectedIndex = 0;
      }
    });
  }

  Future<void> _openEditPage(DeviceModel device) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => EditDeviceScreen(device: device),
      ),
    );
    _refreshDevices();
  }

  Future<void> _navigateToAddDevice() async {
    await Navigator.pushNamed(context, '/add_device');
    _refreshDevices();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthorizing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
        backgroundColor: Color(0xFF00B8FC),
      );
    }

    if (!_authSuccess) {
      return const Scaffold(
        body: Center(child: Text('Access Denied. Check your token.')),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : 2;

    return StreamBuilder<List<ConnectivityResult>>(
      stream: _connectivityService.connectivityStream,
      initialData: const [ConnectivityResult.wifi],
      builder: (context, snapshot) {
        final results = snapshot.data;
        final bool isOffline = results == null ||
            results.contains(ConnectivityResult.none);

        final currentDevice = _devices.isNotEmpty 
            ? _devices[_selectedIndex] 
            : null;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: _buildBackgroundDecoration(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(currentDevice),
                    const SizedBox(height: 32),
                    _buildMyDevicesTitle(isOffline, currentDevice),
                    const SizedBox(height: 12),
                    _buildDeviceSelector(isOffline),
                    const SizedBox(height: 32),
                    _buildSensorGrid(crossAxisCount, isOffline, currentDevice),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Home'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle, size: 40),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
      ),
    );
  }

  Widget _buildHeader(DeviceModel? device) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart meteostation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white70, size: 18),
            const SizedBox(width: 4),
            Text(
              device?.location ?? 'No devices',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMyDevicesTitle(bool isOffline, DeviceModel? device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Devices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (device != null)
          IconButton(
            icon: Icon(
              Icons.edit_note,
              color: isOffline ? Colors.white24 : Colors.white,
            ),
            onPressed: isOffline ? null : () => _openEditPage(device),
          ),
      ],
    );
  }

  Widget _buildDeviceSelector(bool isOffline) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _devices.length + 1,
        itemBuilder: (context, index) {
          if (index == _devices.length) {
            return DeviceButton(
              name: '+ Add New',
              isActive: false,
              onTap: isOffline ? null : _navigateToAddDevice,
            );
          }
          return DeviceButton(
            name: _devices[index].name,
            isActive: _selectedIndex == index,
            onTap: () => setState(() => _selectedIndex = index),
          );
        },
      ),
    );
  }

  Widget _buildSensorGrid(int count, bool isOffline, DeviceModel? device) {
    return StreamBuilder<String>(
      stream: _mqttService.sensorStream,
      builder: (context, mqttSnapshot) {
        String temp = device?.temperature.toString() ?? '--';
        String hum = device?.humidity.toString() ?? '--';

        if (mqttSnapshot.hasData) {
          try {
            final dynamic decoded = jsonDecode(mqttSnapshot.data!);
            if (decoded is Map<String, dynamic>) {
              temp = decoded['temperature']?.toString() ?? temp;
              hum = decoded['humidity']?.toString() ?? hum;
            }
          } catch (e) {
            debugPrint('Error parsing MQTT JSON: $e');
          }
        }

        return Expanded(
          child: GridView.count(
            crossAxisCount: count,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              SensorCard(
                title: 'Temperature',
                value: temp,
                unit: '°C',
                icon: Icons.thermostat,
              ),
              SensorCard(
                title: 'Humidity',
                value: hum,
                unit: '%',
                icon: Icons.water_drop,
              ),
              SensorCard(
                title: 'Pressure',
                value: device?.pressure.toString() ?? '--',
                unit: ' hPa',
                icon: Icons.speed,
              ),
              SensorCard(
                title: 'Status',
                value: device != null 
                    ? (isOffline ? 'Offline' : 'Online') 
                    : '--',
                unit: '',
                icon: isOffline ? Icons.cloud_off : Icons.cloud_done,
              ),
            ],
          ),
        );
      },
    );
  }
}
