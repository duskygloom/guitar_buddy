import 'package:flutter/material.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/audio_utils.dart';
import 'package:guitar_buddy/features/tuner/widgets/spinner.dart';

import 'package:guitar_buddy/features/tuner/widgets/tuner_meter.dart';

class TunerPage extends StatelessWidget {
  const TunerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final futurePermission = AudioUtils.getMicPermission();

    return Scaffold(
      appBar: AppBar(title: Text("Tuner")),
      body: Container(
        padding: EdgeInsets.all(10).copyWith(bottom: kToolbarHeight),
        alignment: Alignment.topCenter,
        child: FutureBuilder(
          future: futurePermission,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final status = snapshot.data!;
              if (status) {
                return TunerMeter();
              } else {
                return AlertDialog(
                  title: Text("Alert"),
                  content: Text("Tuner requires microphone permission."),
                );
              }
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("Failed to check microphone permission."),
              );
            } else {
              return Spinner();
            }
          },
        ),
      ),
    );
  }
}
