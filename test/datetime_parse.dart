import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

void main() {
  final input = '2026 02 27 18 46 13';

  final dt = DateFormat('yyyy MM dd HH mm ss').parse(input);

  if (kDebugMode) {
    print(dt);
  } // 2026-02-27 18:46:13.000
}
