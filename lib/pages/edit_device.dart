import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/repositories/device_repository.dart';
import 'package:flutter_application_1/data/repositories/local_device_repository.dart';
import 'package:flutter_application_1/domain/validators.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';

class EditDeviceScreen extends StatefulWidget {
  final DeviceModel device;

  const EditDeviceScreen({required this.device, super.key});

  @override
  State<EditDeviceScreen> createState() => _EditDeviceScreenState();
}

class _EditDeviceScreenState extends State<EditDeviceScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  final _formKey = GlobalKey<FormState>();
  final DeviceRepository _deviceRepository = LocalDeviceRepository();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _locationController = TextEditingController(text: widget.device.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final updatedDevice = DeviceModel(
        id: widget.device.id,
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        temperature: widget.device.temperature,
        humidity: widget.device.humidity,
        pressure: widget.device.pressure,
      );

      await _deviceRepository.updateDevice(updatedDevice);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _handleDelete() async {
    await _deviceRepository.deleteDevice(widget.device.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Device',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed: _handleDelete,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const Icon(
                      Icons.settings_suggest,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 40),
                    CustomTextField(
                      label: 'Device Name',
                      icon: Icons.devices,
                      controller: _nameController,
                      validator: AppValidators.validateName,
                    ),
                    CustomTextField(
                      label: 'Location',
                      icon: Icons.location_on,
                      controller: _locationController,
                      validator: (v) => v!.isEmpty ? 'Enter location' : null,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _handleUpdate,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
