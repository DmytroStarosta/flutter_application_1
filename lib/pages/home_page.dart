import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/device_button.dart';
import 'package:flutter_application_1/widgets/sensor_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 4 : 2;

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
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Lviv, Ukraine',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'My Devices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      DeviceButton(
                        name: 'Main Station',
                        isActive: true,
                        onTap: () {},
                      ),
                      DeviceButton(
                        name: 'Bedroom Station',
                        isActive: false,
                        onTap: () {},
                      ),
                      DeviceButton(
                        name: 'Kitchen Station',
                        isActive: false,
                        onTap: () {},
                      ),
                      DeviceButton(
                        name: '+ Add New',
                        isActive: false,
                        onTap: () => Navigator.pushNamed(context, '/add_device'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: const [
                      SensorCard(
                        title: 'Temperature',
                        value: '24',
                        unit: '°C',
                        icon: Icons.thermostat,
                      ),
                      SensorCard(
                        title: 'Humidity',
                        value: '45',
                        unit: '%',
                        icon: Icons.water_drop,
                      ),
                      SensorCard(
                        title: 'Pressure',
                        value: '1013',
                        unit: ' hPa',
                        icon: Icons.speed,
                      ),
                      SensorCard(
                        title: 'Status',
                        value: 'Online',
                        unit: '',
                        icon: Icons.cloud_done,
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
