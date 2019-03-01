import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class AppData {
  static final AppData _singleton = new AppData._internal();

  StreamSubscription streamSubscription;
  double scaleFactorW = 0;
  double scaleFactorH = 0;
  double scaleFactorA = 0;
  Map nativeData = new Map();
  List updateIds = new List();
  static Color appColor =
      HSLColor.fromAHSL(1.0, Random().nextDouble() * 360, 0.75, 0.7).toColor();
  Map<Key, Function> setStateCallbacks = new Map();
  ThemeData appTheme = ThemeData(
      brightness: Brightness.dark,
      toggleableActiveColor: appColor,
      accentColor: appColor,
      primarySwatch: MaterialColor(AppData.appColor.value, {
        50: HSLColor.fromColor(AppData.appColor).withLightness(0.1).toColor(),
        100: HSLColor.fromColor(AppData.appColor).withLightness(0.2).toColor(),
        200: HSLColor.fromColor(AppData.appColor).withLightness(0.3).toColor(),
        300: HSLColor.fromColor(AppData.appColor).withLightness(0.4).toColor(),
        400: HSLColor.fromColor(AppData.appColor).withLightness(0.5).toColor(),
        500: HSLColor.fromColor(AppData.appColor).withLightness(0.6).toColor(),
        600: HSLColor.fromColor(AppData.appColor).withLightness(0.7).toColor(),
        700: HSLColor.fromColor(AppData.appColor).withLightness(0.8).toColor(),
        800: HSLColor.fromColor(AppData.appColor).withLightness(0.9).toColor(),
        900: HSLColor.fromColor(AppData.appColor).withLightness(1).toColor()
      }));

  factory AppData() {
    return _singleton;
  }

  AppData._internal();
}
