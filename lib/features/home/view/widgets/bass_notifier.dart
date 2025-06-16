import 'package:flutter_riverpod/flutter_riverpod.dart';

class BassNotifier extends StateNotifier<double> {
  BassNotifier() : super(0.5); 

  void setBass(double value) {
    state = value;
  }
}

final bassNotifierProvider = StateNotifierProvider<BassNotifier, double>((ref) {
  return BassNotifier();
});
