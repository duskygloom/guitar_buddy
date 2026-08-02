import 'package:flutter/material.dart';
import 'package:guitar_buddy/features/library/utils/date_time_utils.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class RecordBtn extends StatelessWidget {
  const RecordBtn({
    super.key,
    required this.recording,
    required this.onPressed,
    this.recordDuration = Duration.zero,
  });

  final bool recording;
  final void Function() onPressed;
  final Duration recordDuration;

  @override
  Widget build(BuildContext context) {
    if (recording) {
      return FloatingActionButton.extended(
        foregroundColor: ColorScheme.of(context).onErrorContainer,
        backgroundColor: ColorScheme.of(context).errorContainer,
        onPressed: onPressed,
        tooltip: "Save",
        icon: Icon(Symbols.stop_rounded, size: kDefaultFontSize * 1.5),
        label: Text(DateTimeUtils.formatDuration(recordDuration)),
      );
    } else {
      return FloatingActionButton(
        onPressed: onPressed,
        tooltip: "Record",
        child: Icon(
          Symbols.radio_button_checked_rounded,
          size: kDefaultFontSize * 1.5,
        ),
      );
    }
  }
}
