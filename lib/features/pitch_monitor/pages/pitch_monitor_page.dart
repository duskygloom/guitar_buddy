import 'package:flutter/material.dart';
import 'package:guitar_buddy/features/pitch_monitor/utils/audio_utils.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/pitch_info.dart';
import 'package:guitar_buddy/features/pitch_monitor/widgets/pitch_monitor.dart';
import 'package:guitar_buddy/features/tuner/widgets/spinner.dart';

class PitchMonitorPage extends StatelessWidget {
  const PitchMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final futurePermission = AudioUtils.getMicPermission();

    return Scaffold(
      appBar: AppBar(title: Text("Pitch Monitor"), actions: [
          
        ],
      ),
      body: FutureBuilder(
        future: futurePermission,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final permitted = snapshot.data!;
            if (permitted) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  spacing: 10,
                  children: [
                    Expanded(child: PitchMonitor()),
                    PitchInfo(),
                  ],
                ),
              );
            } else {
              return AlertDialog(
                title: Text("Alert"),
                content: Text("Pitch Monitor requires microphone permission."),
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
    );
  }
}
