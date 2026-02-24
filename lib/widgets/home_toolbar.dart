import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class HomeToolbar extends StatelessWidget {
  const HomeToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [
      _Tooltile(
        title: "Tuner",
        icon: Symbols.speed_rounded,
        onPressed: () {
          // tune your instrument
        },
      ),
      _Tooltile(
        title: "Metronome",
        icon: Symbols.timer_rounded,
        onPressed: () {
          // tick tick tick tick
        },
      ),
      _Tooltile(
        title: "Chord library",
        icon: Symbols.book_ribbon_rounded,
        onPressed: () {
          // lists different chords
        },
      ),
      _Tooltile(
        title: "Song sync",
        icon: Symbols.sync_rounded,
        onPressed: () {
          // sync songs from a remote server
        },
      ),
    ];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) =>
            SizedBox(width: 150, child: items[index]),
        separatorBuilder: (context, index) => SizedBox(width: 10),
      ),
    );
  }
}

class _Tooltile extends StatelessWidget {
  const _Tooltile({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 5,
            children: [
              Icon(icon, size: 25),
              Text(title, style: TextTheme.of(context).titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
