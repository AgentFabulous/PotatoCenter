import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_data.dart';

void triggerCallbacks(dynamic nativeMap) {
  AppData().setStateCallbacks.forEach((key, Function cb) {
    cb(() {
      AppData().nativeData = nativeMap;
    });
  });
}

void registerCallback(Key k, Function cb) {
  AppData().setStateCallbacks[k] = cb;
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

int totalSizeInMb() {
  return int.parse(AppData().nativeData['size']) ~/ (1024 * 1024);
}

int totalCompletedInMb() {
  return ((int.parse(AppData().nativeData['size']) ~/ (1024 * 1024)) *
          (int.parse(filterPercentage(AppData().nativeData['percentage'])) /
              100))
      .toInt();
}

void launchUrl(String url) async {
  if (await canLaunch(url))
    await launch(url);
  else
    throw 'Could not launch $url!';
}
