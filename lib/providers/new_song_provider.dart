import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newSongFormKeyProvider = Provider((ref) => GlobalKey<FormState>());

final newSongTitleProvider = Provider((ref) => TextEditingController());
final newSongArtistProvider = Provider((ref) => TextEditingController());
final newSongContentProvider = Provider((ref) => TextEditingController());
