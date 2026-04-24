import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/validators.dart';
import 'package:flutter_application_1/logic/cubits/device_cubit.dart';
import 'package:flutter_application_1/logic/cubits/device_state.dart';
import 'package:flutter_application_1/widgets/custom_button.dart';
import 'package:flutter_application_1/widgets/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _onAddPressed() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      context.read<DeviceCubit>().createDevice(
            _nameController.text.trim(),
            _locationController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Device'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<DeviceCubit, DeviceState>(
        listener: (context, state) {
          if (_isSubmitting && !state.isLoading && state.error == null) {
            Navigator.pop(context);
          } else if (state.error != null) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        child: DecoratedBox(
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
                    BlocBuilder<DeviceCubit, DeviceState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const CircularProgressIndicator(
                            color: Colors.white,
                          );
                        }
                        return CustomButton(
                          text: 'Add Device',
                          onPressed: _onAddPressed,
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
