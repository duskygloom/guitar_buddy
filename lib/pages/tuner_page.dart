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
        return await Permission.microphone.status;
      }
      return PermissionStatus.granted;
    }

    Future<PermissionStatus> futureRequestPermission() async {
      if (Platform.isAndroid) {
        final permission = await Permission.microphone.request();
        return permission;
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
                return FutureBuilder(
                  future: futureRequestPermission(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      if (data == PermissionStatus.granted) {
                        return TunerMeter();
                      }
                      return AlertDialog(
                        title: Text("Alert"),
                        content: Text(
                          "Manually grant permission to record audio to proceed.",
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text(snapshot.error.toString()),
                      );
                    } else {
                      return AlertDialog(
                        title: Text("Alert"),
                        content: Text(
                          "Grant permission to record audio to proceed.",
                        ),
                      );
                    }
                  },
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
