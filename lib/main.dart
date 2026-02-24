import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/main_theme.dart';
import 'package:guitar_buddy/models/database.dart';
import 'package:guitar_buddy/pages/home_page.dart';

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
      routes: {"/": (context) => HomePage()},
      initialRoute: "/",
      title: "Guitar Buddy",
      theme: MainTheme.darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
