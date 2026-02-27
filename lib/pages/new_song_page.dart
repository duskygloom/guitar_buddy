import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/providers/new_song_provider.dart';

class NewSongPage extends ConsumerWidget {
  const NewSongPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? emptyValidator(value) {
      if (value == null || value.isEmpty) {
        return "Cannot be empty";
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: Text("New Song")),
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
              ),
              TextFormField(
                controller: ref.watch(newSongArtistProvider),
                decoration: InputDecoration(labelText: "Artist"),
                validator: emptyValidator,
              ),
              Expanded(
                child: TextFormField(
                  controller: ref.watch(newSongContentProvider),
                  maxLines: 100000,
                  decoration: InputDecoration(
                    labelText: "Content",
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              _SaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends ConsumerStatefulWidget {
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
        setState(() {
          loading = true;
        });
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
      },
      child: loading
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeCap: StrokeCap.round),
              ),
            )
          : Text("Save"),
    );
  }
}
