import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sleepTimerNotifierProvider = StateNotifierProvider<SleepTimerNotifier, Duration?>(
  (ref) => SleepTimerNotifier(),
);

class SleepTimerNotifier extends StateNotifier<Duration?> {
  SleepTimerNotifier() : super(null);

  Timer? _timer;

  void setSleepTimer(Duration duration, Function stopPlayback) {
    cancelSleepTimer(); 
    state = duration;

    _timer = Timer(duration, () {
      stopPlayback();
      state = null;
    });
  }

  void cancelSleepTimer() {
    _timer?.cancel();
    state = null;
  }
}
