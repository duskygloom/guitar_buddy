import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/providers/song_view_provider.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class SongViewSettingDialog extends StatelessWidget {
  const SongViewSettingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: kToolbarHeight, right: 10),
      child: AlertDialog(
        alignment: Alignment.topRight,
        clipBehavior: Clip.antiAlias,
        title: AppBar(
          title: Text("Settings"),
          backgroundColor: ColorScheme.of(context).surfaceContainer,
        ),
        titlePadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Consumer(
              builder: (context, ref, child) => _NumberInputTile(
                title: "Scroll speed",
                value: "${ref.watch(speedProvider)}",
                addFunction: () {
                  if (ref.read(speedProvider) < maxSpeed) {
                    ref.read(speedProvider.notifier).state += 0.5;
                  }
                },
                removeFunction: () {
                  if (ref.read(speedProvider) > minSpeed) {
                    ref.read(speedProvider.notifier).state -= 0.5;
                  }
                },
              ),
            ),
            Consumer(
              builder: (context, ref, child) => _NumberInputTile(
                title: "Transpose",
                value: "${ref.watch(transposeProvider)}",
                addFunction: () {
                  if (ref.read(transposeProvider) < maxTranspose) {
                    ref.read(transposeProvider.notifier).state++;
                  }
                },
                removeFunction: () {
                  if (ref.read(transposeProvider) > minTranspose) {
                    ref.read(transposeProvider.notifier).state--;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberInputTile extends StatelessWidget {
  const _NumberInputTile({
    required this.title,
    required this.value,
    required this.addFunction,
    required this.removeFunction,
  });

  final String title, value;
  final Function addFunction, removeFunction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: () {
                removeFunction();
              },
              icon: Icon(Symbols.remove_rounded),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                enabled: false,
                textAlign: TextAlign.center,
                controller: TextEditingController(text: value),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () {
                addFunction();
              },
              icon: Icon(Symbols.add_rounded),
            ),
          ],
        ),
        Text(title),
      ],
    );
  }
}
