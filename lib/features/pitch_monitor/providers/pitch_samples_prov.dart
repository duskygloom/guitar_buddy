import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guitar_buddy/features/pitch_monitor/models/pitch_store.dart';
import 'package:guitar_buddy/features/pitch_monitor/models/pitch.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';

final pitchSamplesProv = NotifierProvider(
  () => PitchSamplesNotifier(recordSecs: 15),
);

class PitchSamplesNotifier extends Notifier<PitchStore> {
  final int recordSecs;

  PitchSamplesNotifier({required this.recordSecs});

  @override
  PitchStore build() {
    return PitchStore(pitches: [], endMarkers: []);
  }

  void addPitch(PitchDetectorResult? result) {
    if (result == null) {
      // used to refresh state without doing anything
      state = PitchStore(
        pitches: state.pitches,
        endMarkers: state.endMarkers,
        lastPitchResult: state.lastPitchResult,
      );
      return;
    }

    // base case: when store is empty
    final currentTime = DateTime.now();
    if (state.pitches.isEmpty) {
      state = PitchStore(
        pitches: [Pitch(currentTime, result.pitch)],
        endMarkers: [1],
      );
      return;
    }

    // remove old pitches
    final pitches = state.pitches;
    final oldestTime = currentTime.subtract(Duration(seconds: recordSecs * 5));
    var startIndex = 0;
    for (var i = 0; i < pitches.length; i++) {
      if (pitches[i].time.compareTo(oldestTime) < 0) {
        startIndex = i + 1;
      } else {
        break;
      }
    }
    final newPitches = pitches.sublist(startIndex);

    // update markers
    final newMarkers = state.endMarkers
        .map((marker) => marker - startIndex)
        .where((marker) => marker >= 0)
        .toList();

    // add new pitch and marker
    if (newPitches.isEmpty) {
      state = PitchStore(
        pitches: [Pitch(currentTime, result.pitch)],
        endMarkers: [1],
      );
      return;
    } else if (result.pitch < 20 && newPitches.last.frequency < 20) {
      // extend marker
      if (newMarkers.isEmpty) {
        newMarkers.add(1);
      } else {
        newMarkers[newMarkers.length - 1] += 1;
      }
    } else if (result.pitch < 20) {
      final timeSinceLast = currentTime.difference(newPitches.last.time);
      // timeout, add new marker
      if (timeSinceLast.compareTo(PitchStore.sampleTimeout) > 0) {
        newMarkers.add(newPitches.length + 1);
      }
      // in time, extend the last sample
      else if (newMarkers.isEmpty) {
        newMarkers.add(1);
      } else {
        newMarkers[newMarkers.length - 1] += 1;
      }
      // add new marker
      newMarkers.add(newPitches.length + 1);
    } else {
      final timeSinceLast = currentTime.difference(newPitches.last.time);
      // timeout, add new marker
      if (timeSinceLast.compareTo(PitchStore.sampleTimeout) > 0) {
        newMarkers.add(newPitches.length + 1);
      }
      // in time, extend the last sample
      else if (newMarkers.isEmpty) {
        newMarkers.add(1);
      } else {
        newMarkers[newMarkers.length - 1] += 1;
      }
    }
    newPitches.add(Pitch(currentTime, result.pitch));

    // update state
    state = PitchStore(
      pitches: newPitches,
      endMarkers: newMarkers,
      lastPitchResult: result.pitch > 0 ? result : state.lastPitchResult,
    );
  }
}
