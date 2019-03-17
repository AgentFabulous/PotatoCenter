import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_data.dart';

void triggerCallbacks(dynamic nativeMap, {bool force = false}) {
  AppData().setStateCallbacks.forEach((key, data) {
    if (data[1] || force || strToBool(nativeMap['force_update_ui']))
      AndroidFlutterUpdater.getDownloads().then((v) => data[0](() {
            AppData().nativeData = nativeMap;
            AppData().updateIds = v;
          }));
  });
}

void registerCallback(Key k, Function cb, {bool critical = false}) {
  dynamic data = [cb, critical];
  AppData().setStateCallbacks[k] = data;
}

void unregisterCallback(Key k) {
  AppData().setStateCallbacks.remove(k);
}

dynamic strToStatusEnum(String value) {
  return UpdateStatus.values.firstWhere(
      (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
}

bool strToBool(String ip) {
  return ip == null ? false : ip.toLowerCase() == "true";
}

String filterPercentage(String ip) {
  return ip.replaceAll(new RegExp(r'%'), '');
}

String statusCapitalize(String s) {
  s = s.split('.')[1];
  s = strToStatusEnum(s) == UpdateStatus.PAUSED_ERROR ? "cancelled" : s;
  return (s[0].toUpperCase() + s.toLowerCase().substring(1))
      .replaceAll(new RegExp(r'_'), ' ');
}

bool statusEnumCheck(UpdateStatus u) {
  return strToStatusEnum(AppData().nativeData['update_status']) == u;
}

int totalSizeInMb({String sizeStr}) {
  sizeStr ??= AppData().nativeData['size'];
  return int.parse(sizeStr) ~/ (1024 * 1024);
}

int totalCompletedInMb({String sizeStr, String percentageStr}) {
  sizeStr ??= AppData().nativeData['size'];
  percentageStr ??= AppData().nativeData['percentage'];
  return ((int.parse(sizeStr) ~/ (1024 * 1024)) *
          (int.parse(filterPercentage(percentageStr)) / 100))
      .toInt();
}

Future<bool> activeLayout(String id) async {
  bool ret = false;
  int persistStatus = await AndroidFlutterUpdater.getPersistentStatus(id);
  switch (persistStatus) {
    case Persistent.UNKNOWN:
      ret = strToStatusEnum(await AndroidFlutterUpdater.getStatus(id)) ==
          UpdateStatus.STARTING;
      break;
    case Persistent.VERIFIED:
      ret = strToStatusEnum(await AndroidFlutterUpdater.getStatus(id)) ==
          UpdateStatus.INSTALLING;
      break;
    case Persistent.INCOMPLETE:
      ret = true;
      break;
    default:
      throw new Exception("Bad Persistent Status: $persistStatus");
  }
  return ret;
}

Future<String> getDownloadStatusLine(String id) async {
  return "${await AndroidFlutterUpdater.getEta(id)} (${totalCompletedInMb(percentageStr: (await AndroidFlutterUpdater.getDownloadProgress(id)).toString())}MB of ${totalSizeInMb(sizeStr: await AndroidFlutterUpdater.getSize(id))}MB)";
}

void launchUrl(String url) async {
  if (await canLaunch(url))
    await launch(url);
  else
    throw 'Could not launch $url!';
}

Future<void> handleAdvancedMode() async {
  bool advancedModeEnabled = await getAdvancedMode();
  if (!advancedModeEnabled) {
    // Advanced mode not enabled
    // Check and set
    if (++AppData().advancedMode >= 10) {
      triggerCallbacks(AppData().nativeData, force: true);
      setAdvancedMode(true);
    }
  } else {
    // Advanced mode enabled
    // This means app has just started
    if (AppData().advancedMode < 10) triggerCallbacks(AppData().nativeData);
  }
}

Future<bool> getAdvancedMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('advanced_mode') ?? false;
}

Future<void> setAdvancedMode(bool enable) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('advanced_mode', enable);
}

Future<bool> getLightTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('light_theme') ?? false;
}

Future<void> setLightTheme(bool light) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('light_theme', light);
  AppData().setLight(light);
}
