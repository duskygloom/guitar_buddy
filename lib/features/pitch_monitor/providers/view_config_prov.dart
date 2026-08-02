import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/models/chart_view_config.dart';

final viewConfigProv = NotifierProvider(() => ViewConfigNotifier());

class ViewConfigNotifier extends Notifier<ChartViewConfig> {
  static const minStartNote = 12.0;

  static const minNotesInView = 6;
  static const maxNotesInView = 36;

  @override
  ChartViewConfig build() {
    // return ChartViewConfig(startNote: 36, notesInView: 18);
    return ChartViewConfig(startNote: 38, notesInView: 49);
  }

  void setStartNote(double note) {
    final maxStartNote = 120.0 - state.notesInView;
    state = ChartViewConfig(
      startNote: note.clamp(minStartNote, maxStartNote),
      notesInView: state.notesInView,
    );
  }

  void setNotesInView(int n) {
    state = ChartViewConfig(
      startNote: state.startNote,
      notesInView: n.clamp(minNotesInView, maxNotesInView),
    );
  }
}
