import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final libraryRefreshKeyProvider = Provider(
  (ref) => GlobalKey<RefreshIndicatorState>(),
);

final libraryScrollingProvider = StateProvider((ref) => false);
