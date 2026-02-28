import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final fontSizeProvider = StateProvider((ref) => kDefaultFontSize);
final transposeProvider = StateProvider((ref) => 0);
final scrollingProvider = StateProvider((ref) => false);
final scrollSpeedProvider = StateProvider((ref) => 1.0);
final showSettingsProvider = StateProvider((ref) => false);

const minFontSize = 10.0;
const maxFontSize = 20.0;

const minSpeed = 0.5;
const maxSpeed = 5.0;

const minTranspose = -12;
const maxTranspose = 12;
