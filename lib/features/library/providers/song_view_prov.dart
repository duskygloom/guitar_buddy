import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongViewConfig {
  final double fontSize, scrollSpeed;
  final int transpose, columns;
  final bool showSettings, scrolling, autoScrolling;

  static const minFontSize = 10.0;
  static const maxFontSize = 40.0;

  static const minSpeed = 0.5;
  static const maxSpeed = 5.0;

  static const minTranspose = -12;
  static const maxTranspose = 12;

  static const minColumns = 1;
  static const maxColumns = 4;

  const SongViewConfig({
    required this.fontSize,
    required this.scrollSpeed,
    required this.transpose,
    required this.columns,
    required this.showSettings,
    required this.scrolling,
    required this.autoScrolling,
  });

  SongViewConfig copyWith({
    double? fontSize,
    double? scrollSpeed,
    int? transpose,
    int? columns,
    bool? showSettings,
    bool? scrolling,
    bool? autoScrolling,
  }) {
    return SongViewConfig(
      fontSize: fontSize ?? this.fontSize,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      transpose: transpose ?? this.transpose,
      columns: columns ?? this.columns,
      showSettings: showSettings ?? this.showSettings,
      scrolling: scrolling ?? this.scrolling,
      autoScrolling: autoScrolling ?? this.autoScrolling,
    );
  }
}

class SongViewConfigProv extends Notifier<SongViewConfig> {
  @override
  SongViewConfig build() {
    return SongViewConfig(
      fontSize: kDefaultFontSize,
      scrollSpeed: 1.0,
      transpose: 0,
      columns: 1,
      scrolling: false,
      showSettings: false,
      autoScrolling: false,
    );
  }

  void transposeUp() {
    if (state.transpose < SongViewConfig.maxTranspose) {
      state = state.copyWith(transpose: state.transpose + 1);
    }
  }

  void transposeDown() {
    if (state.transpose > SongViewConfig.minTranspose) {
      state = state.copyWith(transpose: state.transpose - 1);
    }
  }

  void setTranspose(int transpose) {
    state = state.copyWith(
      transpose: transpose.clamp(
        SongViewConfig.minTranspose,
        SongViewConfig.maxTranspose,
      ),
    );
  }

  void speedUp() {
    if (state.scrollSpeed < SongViewConfig.maxSpeed) {
      state = state.copyWith(scrollSpeed: state.scrollSpeed + 0.5);
    }
  }

  void speedDown() {
    if (state.scrollSpeed > SongViewConfig.minSpeed) {
      state = state.copyWith(scrollSpeed: state.scrollSpeed - 0.5);
    }
  }

  void setSpeed(double speed) {
    state = state.copyWith(
      scrollSpeed: speed.clamp(
        SongViewConfig.minSpeed,
        SongViewConfig.maxSpeed,
      ),
    );
  }

  void fontSizeUp() {
    if (state.fontSize < SongViewConfig.maxFontSize) {
      state = state.copyWith(fontSize: state.fontSize + 1);
    }
  }

  void fontSizeDown() {
    if (state.fontSize > SongViewConfig.minFontSize) {
      state = state.copyWith(fontSize: state.fontSize - 1);
    }
  }

  void setFontSize(double size) {
    state = state.copyWith(
      fontSize: size.clamp(
        SongViewConfig.minFontSize,
        SongViewConfig.maxFontSize,
      ),
    );
  }

  void columnsIncr() {
    if (state.columns < SongViewConfig.maxColumns) {
      state = state.copyWith(columns: state.columns + 1);
    }
  }

  void columnsDecr() {
    if (state.columns > SongViewConfig.minColumns) {
      state = state.copyWith(columns: state.columns - 1);
    }
  }

  void toggleSettings() {
    state = state.copyWith(showSettings: !state.showSettings);
  }

  void toggleAutoscroll() {
    state = state.copyWith(autoScrolling: !state.autoScrolling);
  }

  void startScrolling() {
    state = state.copyWith(scrolling: true);
  }

  void stopScrolling() {
    state = state.copyWith(scrolling: false);
  }
}

final songViewConfigProv = NotifierProvider(() => SongViewConfigProv());
