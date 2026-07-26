import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newSongFormKeyProv = Provider((ref) => GlobalKey<FormState>());

final newSongTitleProv = Provider((ref) => TextEditingController());
final newSongArtistProv = Provider((ref) => TextEditingController());
final newSongContentProv = Provider((ref) => TextEditingController());
