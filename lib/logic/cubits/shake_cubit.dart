import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ShakeState {
  final int count;
  ShakeState(this.count);
}

class ShakeCubit extends Cubit<ShakeState> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Timer? _timer;

  ShakeCubit() : super(ShakeState(0));

  void init() {
    _startTimer();
  }

  Future<void> shake() async {
    emit(ShakeState(state.count + 1));
    _sendToFirebase(state.count);
  }

  Future<void> _sendToFirebase(int count) async {
    try {
      final String formattedDate = DateFormat(
        'yyyy-MM-dd HH:mm:ss'
      ).format(DateTime.now());

      await _dbRef.child('shake_events').set({
        'timestamp': formattedDate,
        'shake_count': count,
      });
      debugPrint('Firebase: Sent $count shakes at $formattedDate');
    } catch (e) {
      debugPrint('Firebase Error: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      emit(ShakeState(0));
      _sendToFirebase(state.count);
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
