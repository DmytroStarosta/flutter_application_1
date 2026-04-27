import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/logic/cubits/device_cubit.dart';
import 'package:flutter_application_1/logic/cubits/device_state.dart';
import 'package:flutter_application_1/widgets/device_button.dart';
import 'package:flutter_application_1/widgets/sensor_grid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DeviceCubit>().loadDevices();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 40),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          )
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<DeviceCubit, DeviceState>(
            builder: (context, state) {
              if (state.isLoading && state.devices.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final List<DeviceModel> devs = state.devices;
              final DeviceModel? dev =
                  devs.isEmpty ? null : devs[state.selectedIdx];

              return Padding(
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
                    _buildLocation(dev?.location ?? 'No devices'),
                    const SizedBox(height: 32),
                    _buildHeader(context, dev),
                    _buildDeviceList(context, devs, state.selectedIdx),
                    const SizedBox(height: 32),
                    SensorGrid(dev: dev, mqttData: state.mqttData),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLocation(String location) => Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white70),
          Text(
            location,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          )
        ],
      );

  Widget _buildHeader(BuildContext context, DeviceModel? dev) => Row(
        children: [
          const Text(
            'My Devices',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const Spacer(),
          if (dev != null)
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.white),
              onPressed: () => Navigator.pushNamed(
                context,
                '/edit_device',
                arguments: dev,
              ),
            )
        ],
      );

  Widget _buildDeviceList(
    BuildContext context,
    List<DeviceModel> devs,
    int selIdx,
  ) =>
      SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: devs.length + 1,
          itemBuilder: (c, i) {
            if (i == devs.length) {
              return DeviceButton(
                name: '+ Add',
                isActive: false,
                onTap: () => Navigator.pushNamed(context, '/add_device'),
              );
            }
            return DeviceButton(
              name: devs[i].name,
              isActive: selIdx == i,
              onTap: () => context.read<DeviceCubit>().selectDevice(i),
            );
          },
        ),
      );
}
