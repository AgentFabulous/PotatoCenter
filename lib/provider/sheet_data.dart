import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/foundation.dart';

class SheetDataProvider extends ChangeNotifier {
  SheetDataProvider() {
    loadData();
  }

  int _checkInterval = 2;
  bool _dataWarn = true;
  bool _autoDelete = false;
  bool _isABDevice = false;
  bool _perfMode = false;
  bool _isHandleVisible = true;

  int get checkInterval => _checkInterval;

  bool get dataWarn => _dataWarn;

  bool get autoDelete => _autoDelete;

  bool get isABDevice => _isABDevice;

  bool get perfMode => _perfMode;

  bool get isHandleVisible => _isHandleVisible;

  set checkInterval(int val) {
    _checkInterval = val;
    AndroidFlutterUpdater.setUpdateCheckSetting(val);
    notifyListeners();
  }

  set dataWarn(bool val) {
    _dataWarn = val;
    AndroidFlutterUpdater.setWarn(val);
    notifyListeners();
  }

  set autoDelete(bool val) {
    _autoDelete = val;
    AndroidFlutterUpdater.setAutoDelete(val);
    notifyListeners();
  }

  set isABDevice(bool val) {
    _isABDevice = val;
    notifyListeners();
  }

  set perfMode(bool val) {
    _perfMode = val;
    AndroidFlutterUpdater.setPerformanceMode(val);
    notifyListeners();
  }

  set isHandleVisible(bool val) {
    _isHandleVisible = val;
    notifyListeners();
  }

  Future<void> loadData() async {
    checkInterval = await AndroidFlutterUpdater.getUpdateCheckSetting();
    dataWarn = await AndroidFlutterUpdater.getWarn();
    autoDelete = await AndroidFlutterUpdater.getAutoDelete();
    isABDevice = await AndroidFlutterUpdater.isABDevice();
    perfMode = await AndroidFlutterUpdater.getPerformanceMode();

  }
}
