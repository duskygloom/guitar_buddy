import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/models/song.dart';
import 'package:guitar_buddy/providers/home_page_provider.dart';
import 'package:guitar_buddy/providers/new_song_provider.dart';

class NewSongPage extends ConsumerWidget {
  const NewSongPage({super.key, this.songId});

  final String? songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? emptyValidator(value) {
      if (value == null || value.isEmpty) {
        return "Cannot be empty";
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(songId == null ? "New Song" : "Edit Song")),
      body: Form(
        key: ref.watch(newSongFormKeyProvider),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: ref.watch(newSongTitleProvider),
                decoration: InputDecoration(labelText: "Title"),
                validator: emptyValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              TextFormField(
                controller: ref.watch(newSongArtistProvider),
                decoration: InputDecoration(labelText: "Artist"),
                validator: emptyValidator,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
              ),
              Expanded(
                child: TextFormField(
                  controller: ref.watch(newSongContentProvider),
                  maxLines: 10000,
                  decoration: InputDecoration(
                    labelText: "Content",
                    alignLabelWithHint: true,
                  ),
                  textInputAction: TextInputAction.newline,
                ),
              ),
              _SaveButton(songId: songId),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends ConsumerStatefulWidget {
  const _SaveButton({this.songId});

  final String? songId;

  @override
  ConsumerState<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends ConsumerState<_SaveButton> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.fromHeight(40)),
      ),
      onPressed: () async {
        final formKey = ref.watch(newSongFormKeyProvider);
        if (formKey.currentState?.validate() != true) {
          return;
        }
        setState(() => loading = true);
        try {
          await Song.store(
            Song(
              title: ref.watch(newSongTitleProvider).text,
              artist: ref.watch(newSongArtistProvider).text,
              content: ref.watch(newSongContentProvider).text,
            ),
            songId: widget.songId,
          );
          await Future.delayed(Duration(milliseconds: 500));
          if (mounted) {
            setState(() => loading = false);
          }
          if (context.mounted) {
            Navigator.pop(context);
            await ref.read(libraryRefreshKeyProvider).currentState?.show();
          }
        } catch (e) {
          await Future.delayed(Duration(milliseconds: 500));
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Error"),
                content: Text(e.toString()),
              ),
            );
          }
          if (mounted) {
            setState(() => loading = false);
          }
        }
      },
      child: loading
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: ColorScheme.of(context).onTertiary,
                ),
              ),
            )
          : Text("Save"),
    );
  }
}
