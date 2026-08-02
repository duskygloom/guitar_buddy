import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  const Spinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: kDefaultFontSize * 2,
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
          strokeWidth: 4,
        ),
      ),
    );
  }
}
