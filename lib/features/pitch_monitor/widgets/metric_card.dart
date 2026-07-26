import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final Widget child;

  const MetricCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      color: ColorScheme.of(context).surfaceContainerLow,
      child: Container(
        height: kDefaultFontSize * 7.5,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text(
              title,
              style: TextStyle(
                color: ColorScheme.of(context).onSurface.withAlpha(150),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
