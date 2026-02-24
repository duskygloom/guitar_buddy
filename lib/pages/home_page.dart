import 'package:flutter/material.dart';
import 'package:guitar_buddy/widgets/home_toolbar.dart';
import 'package:guitar_buddy/widgets/song_library.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Guitar Buddy")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            HomeToolbar(),
            SizedBox(height: 20),
            AppBar(title: Text("Library"), centerTitle: false),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 2));
                },
                child: SongLibrary(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: "New song",
        child: Icon(Symbols.add_rounded),
      ),
    );
  }
}
