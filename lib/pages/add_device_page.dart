import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/services/api_service.dart';
import 'package:flutter_application_1/domain/validators.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});
  @override State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  Future<void> _handleAddDevice() async {
    if (!_formKey.currentState!.validate()) return;

    final newDevice = DeviceModel(
      id: '', 
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      pressure: 1013,
    );

    try {
      await _api.addDevice(newDevice);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add device')),
        );
      }
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Device', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(children: [
                const Icon(Icons.add_to_home_screen, 
                    size: 80, color: Colors.white),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Device Name',
                  controller: _nameController,
                  icon: Icons.devices,
                  validator: AppValidators.validateName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Location',
                  controller: _locationController,
                  icon: Icons.map,
                  validator: (v) => v!.isEmpty ? 'Enter location' : null,
                ),
                const SizedBox(height: 32),
                CustomButton(text: 'Add Device', onPressed: _handleAddDevice),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
