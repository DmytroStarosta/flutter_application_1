import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/data/repositories/local_device_repository.dart';
import 'package:flutter_application_1/data/services/mqtt_service.dart';
import 'package:flutter_application_1/domain/validators.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';

class EditDeviceScreen extends StatefulWidget {
  final DeviceModel device;
  const EditDeviceScreen({required this.device, super.key});
  @override State<EditDeviceScreen> createState() => _EditDeviceScreenState();
}

class _EditDeviceScreenState extends State<EditDeviceScreen> {
  late final TextEditingController _nCtrl, _lCtrl;
  final _formKey = GlobalKey<FormState>();
  final _repo = LocalDeviceRepository();

  @override void initState() {
    super.initState();
    _nCtrl = TextEditingController(text: widget.device.name);
    _lCtrl = TextEditingController(text: widget.device.location);
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = DeviceModel(
      id: widget.device.id,
      name: _nCtrl.text.trim(),
      location: _lCtrl.text.trim(),
      temperature: widget.device.temperature,
      humidity: widget.device.humidity,
      pressure: widget.device.pressure,
    );
    await _repo.updateDevice(updated);
    final mqttData = {'name': updated.name, 'location': updated.location};
    MqttService().publish('weather/config', jsonEncode(mqttData));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Device'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (res == true) {
      await _repo.deleteDevice(widget.device.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Device', 
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _handleDelete,
          ),
        ],
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
                const Icon(Icons.settings, size: 80, color: Colors.white),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Device Name',
                  controller: _nCtrl,
                  icon: Icons.devices,
                  validator: AppValidators.validateName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Location',
                  controller: _lCtrl,
                  icon: Icons.location_on,
                  validator: (v) => v!.isEmpty ? 'Error' : null,
                ),
                const SizedBox(height: 32),
                CustomButton(text: 'Save Changes', onPressed: _handleUpdate),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
