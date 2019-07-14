import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:potato_center/internal/methods.dart';

class AppInfoProvider extends ChangeNotifier {
  AppInfoProvider() {
    loadData();
  }

  bool _isDark = false;
  bool _isDeveloper = false;
  int _splashMode = 0;
  int _devCounter = 0;

  bool get isDark => _isDark;

  bool get isDeveloper => _isDeveloper;

  int get splashMode => _splashMode;

  int get devCounter => _devCounter;

  set isDark(bool val) {
    _isDark = val;
    setDark(val);
    notifyListeners();
  }

  set isDeveloper(bool val) {
    _isDeveloper = val;
    setDeveloperMode(val);
    notifyListeners();
  }

  set splashMode(int val) {
    _splashMode = val;
    notifyListeners();
  }

  set devCounter(int val) {
    _devCounter = val;
    if (val >= 10) {
      devCounter = 0;
      isDeveloper = true;
    }
    notifyListeners();
  }

  Future<void> loadData() async {
    isDark = await getDark();
    isDeveloper = await getDeveloperMode();
  }
}
