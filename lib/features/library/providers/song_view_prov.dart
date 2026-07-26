import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final svFontSizeProv = StateProvider((ref) => kDefaultFontSize);
final svTransposeProv = StateProvider((ref) => 0);
final svScrollingProv = StateProvider((ref) => false);
final svScrollSpeedProv = StateProvider((ref) => 1.0);

final svShowSettingsProv = StateProvider((ref) => false);

final svSongScrollingProv = StateProvider((ref) => false);

const svMinFontSize = 10.0;
const svMaxFontSize = 20.0;

const svMinSpeed = 0.5;
const svMaxSpeed = 5.0;

const svMinTranspose = -12;
const svMaxTranspose = 12;
