import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final libraryRefreshKeyProv = Provider(
  (ref) => GlobalKey<RefreshIndicatorState>(),
);

final libraryScrollingProv = StateProvider((ref) => false);
