import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guitar_buddy/widgets/tuner_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class TunerPage extends StatelessWidget {
  const TunerPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<PermissionStatus> futurePermission() async {
      if (Platform.isAndroid) {
        return await Permission.audio.status;
      }
      return PermissionStatus.granted;
    }

    return Scaffold(
      appBar: AppBar(title: Text("Tuner")),
      body: Padding(
        padding: EdgeInsets.all(10).copyWith(bottom: kToolbarHeight),
        child: FutureBuilder(
          future: futurePermission(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final status = snapshot.data!;
              if (status == PermissionStatus.granted) {
                return TunerMeter();
              } else {
                return Card(
                  child: SizedBox(
                    height: 200,
                    width: 400,
                    child: Text("Audio permission denied."),
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return Card(
                child: SizedBox(
                  height: 200,
                  width: 400,
                  child: Text(snapshot.error!.toString()),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
