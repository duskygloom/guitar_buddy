import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryRefreshKeyProvider = Provider(
  (ref) => GlobalKey<RefreshIndicatorState>(),
);
