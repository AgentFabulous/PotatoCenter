import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/foundation.dart';

class CurrentBuildProvider extends ChangeNotifier {

  CurrentBuildProvider() {
    loadData();
  }

  String _version = '';
  String _device = '';
  String _codename = '';
  String _date = '';
  String _type = '';

  String get version => _version;
  String get device => _device;
  String get codename => _codename;
  String get date => _date;
  String get type => _type;

  set version(String val) {
    _version = val;
    notifyListeners();
  }

  set device(String val) {
    _device = val;
    notifyListeners();
  }

  set codename(String val) {
    _codename = val;
    notifyListeners();
  }

  set date(String val) {
    _date = val;
    notifyListeners();
  }

  set type(String val) {
    _type = val;
    notifyListeners();
  }

  Future<void> loadData() async {
    version = await AndroidFlutterUpdater.getBuildVersion();
    device = await AndroidFlutterUpdater.getModel();
    codename = await AndroidFlutterUpdater.getDeviceName();
    date = await AndroidFlutterUpdater.getBuildDate();
    type = await AndroidFlutterUpdater.getProp("ro.potato.dish");

  }
}