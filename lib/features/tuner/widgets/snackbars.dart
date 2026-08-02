import 'package:flutter/material.dart';

class Snackbars {
  static SnackBar error(BuildContext context, String text) => SnackBar(
    content: Text(
      text,
      style: TextStyle(color: ColorScheme.of(context).onErrorContainer),
    ),
    backgroundColor: ColorScheme.of(context).errorContainer,
  );
}
