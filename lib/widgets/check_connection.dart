import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/conectivity_service.dart';

class CheckConnection extends StatelessWidget {
  final Widget child;

  const CheckConnection({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: ConnectivityService().connectivityStream,
      builder: (context, snapshot) {
        final results = snapshot.data;
        final bool isOffline = results?.contains(
              ConnectivityResult.none,
            ) ??
            false;

        return Stack(
          children: [
            child,
            if (isOffline)
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    color: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    child: const Text(
                      'No Internet Connection - Limited Mode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
