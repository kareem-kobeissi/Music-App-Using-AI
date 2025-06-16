import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurroundSoundNotifier extends StateNotifier<bool> {
  SurroundSoundNotifier() : super(false); 

  void setSurroundSound(bool enabled) {
    state = enabled;
  }
}

final surroundSoundNotifierProvider = StateNotifierProvider<SurroundSoundNotifier, bool>((ref) {
  return SurroundSoundNotifier();
});
