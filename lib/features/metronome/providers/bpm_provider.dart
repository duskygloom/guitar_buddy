import 'package:flutter_riverpod/flutter_riverpod.dart';

final bpmProvider = NotifierProvider<BpmNotifier, int>(() => BpmNotifier());

class BpmNotifier extends Notifier<int> {
  @override
  int build() {
    return 120;
  }

  void increment() {
    state++;
  }

  void decrement() {
    state--;
  }

  void updateBpm(int value) {
    state = value;
  }
}
