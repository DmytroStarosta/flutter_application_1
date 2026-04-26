import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/device_model.dart';
import 'package:flutter_application_1/domain/validators.dart';
import 'package:flutter_application_1/logic/cubits/device_cubit.dart';
import 'package:flutter_application_1/logic/cubits/device_state.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditDeviceScreen extends StatefulWidget {
  final DeviceModel device;
  const EditDeviceScreen({required this.device, super.key});

  @override
  State<EditDeviceScreen> createState() => _EditDeviceScreenState();
}

class _EditDeviceScreenState extends State<EditDeviceScreen> {
  late final TextEditingController _nCtrl, _lCtrl;
  final _formKey = GlobalKey<FormState>();
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nCtrl = TextEditingController(text: widget.device.name);
    _lCtrl = TextEditingController(text: widget.device.location);
  }

  @override
  void dispose() {
    _nCtrl.dispose();
    _lCtrl.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    final updated = DeviceModel(
      id: widget.device.id,
      name: _nCtrl.text.trim(),
      location: _lCtrl.text.trim(),
      temperature: widget.device.temperature,
      humidity: widget.device.humidity,
      pressure: widget.device.pressure,
    );
    context.read<DeviceCubit>().editDevice(updated);
  }

  void _handleDelete() async {
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

    if (res == true && mounted) {
      setState(() => _isSaving = true);
      context.read<DeviceCubit>().removeDevice(widget.device.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Device', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: BlocListener<DeviceCubit, DeviceState>(
        listener: (context, state) {
          if (_isSaving && !state.isLoading && state.error == null) {
            Navigator.pop(context);
          } else if (state.error != null) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00B8FC), Color(0xFF079AF7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
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
                    BlocBuilder<DeviceCubit, DeviceState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        }
                        return CustomButton(
                          text: 'Save Changes',
                          onPressed: _handleUpdate,
                        );
                      },
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
