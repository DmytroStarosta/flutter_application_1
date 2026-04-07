import 'package:flutter/material.dart';

class DeviceButton extends StatelessWidget {
  final String name;
  final bool isActive;
  final VoidCallback? onTap;

  const DeviceButton({
    required this.name,
    required this.isActive,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(
                      alpha: isDisabled ? 0.05 : 0.2,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: isDisabled ? 0.1 : 0.3,
                ),
              ),
            ),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  color: isActive 
                      ? const Color(0xFF079AF7) 
                      : Colors.white.withValues(
                          alpha: isDisabled ? 0.4 : 1.0,
                        ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
