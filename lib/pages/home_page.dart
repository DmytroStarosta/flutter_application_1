import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device.model.dart';
import 'package:flutter_application_1/data/repositories/device_repository.dart';
import 'package:flutter_application_1/data/repositories/local_device_repository.dart';
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
  List<DeviceModel> _devices = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshDevices();
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

  void _openEditPage(DeviceModel device) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => EditDeviceScreen(device: device),
      ),
    );
    _refreshDevices();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : 2;
    final currentDevice = _devices.isNotEmpty ? _devices[_selectedIndex] : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.account_circle,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
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
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      currentDevice?.location ?? 'No devices',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
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
                    if (currentDevice != null)
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.white),
                        onPressed: () => _openEditPage(currentDevice),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _devices.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _devices.length) {
                        return DeviceButton(
                          name: '+ Add New',
                          isActive: false,
                          onTap: () async {
                            await Navigator.pushNamed(context, '/add_device');
                            _refreshDevices();
                          },
                        );
                      }
                      return DeviceButton(
                        name: _devices[index].name,
                        isActive: _selectedIndex == index,
                        onTap: () => setState(() => _selectedIndex = index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      SensorCard(
                        title: 'Temperature',
                        value: currentDevice?.temperature.toString() ?? '--',
                        unit: '°C',
                        icon: Icons.thermostat,
                      ),
                      SensorCard(
                        title: 'Humidity',
                        value: currentDevice?.humidity.toString() ?? '--',
                        unit: '%',
                        icon: Icons.water_drop,
                      ),
                      SensorCard(
                        title: 'Pressure',
                        value: currentDevice?.pressure.toString() ?? '--',
                        unit: ' hPa',
                        icon: Icons.speed,
                      ),
                      SensorCard(
                        title: 'Status',
                        value: currentDevice != null ? 'Online' : 'Offline',
                        unit: '',
                        icon: currentDevice != null
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
