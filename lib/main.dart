import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/pages/pitch_monitor_page.dart';
import 'package:guitar_buddy/main_theme.dart';
import 'package:guitar_buddy/features/library/utils/db_utils.dart';
import 'package:guitar_buddy/features/library/pages/library_page.dart';
import 'package:guitar_buddy/features/metronome/pages/metronome_page.dart';
import 'package:guitar_buddy/features/library/pages/new_song_page.dart';
import 'package:guitar_buddy/features/tuner/pages/tuner_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DButils.initDB();
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => LibraryPage(),
        "/new": (context) => NewSongPage(),
        "/tuner": (context) => TunerPage(),
        "/metronome": (_) => MetronomePage(),
        "/pitchmonitor": (_) => PitchMonitorPage(),
      },
      initialRoute: "/",
      title: "Guitar Buddy",
      themeMode: ThemeMode.system,
      theme: MainTheme.lightTheme,
      darkTheme: MainTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
