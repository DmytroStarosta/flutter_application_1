import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.validator,
    this.isPassword = false,
    super.key,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        validator: widget.validator,
        style: const TextStyle(color: Color(0xFF079AF7)),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
          hintText: widget.label,
          hintStyle: const TextStyle(color: Color(0xFF079AF7)),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixIcon: Icon(widget.icon, color: const Color(0xFF079AF7)),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF079AF7),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          errorStyle: const TextStyle(color: Colors.redAccent, height: 0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }
}
