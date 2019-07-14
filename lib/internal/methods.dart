import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:potato_center/models/download.dart';
import 'package:potato_center/provider/download.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

dynamic strToStatusEnum(String value) {
  return UpdateStatus.values.firstWhere(
      (e) => e.toString().split('.')[1].toUpperCase() == value.toUpperCase());
}

bool strToBool(String ip) {
  return ip == null ? false : ip.toLowerCase().trim() == "true";
}

String filterPercentage(String ip) {
  return ip.replaceAll(new RegExp(r'%'), '');
}

String formatStatus(String status) {
  status = status.split('.')[1];
  status = strToStatusEnum(status) == UpdateStatus.PAUSED_ERROR
      ? "cancelled"
      : status;
  return (status[0].toUpperCase() + status.toLowerCase().substring(1))
      .replaceAll(new RegExp(r'_'), ' ');
}

int totalSizeInMb({String sizeStr}) {
  sizeStr ??= '0';
  return int.parse(sizeStr) ~/ (1024 * 1024);
}

int totalCompletedInMb({String sizeStr, String percentageStr}) {
  sizeStr ??= '0';
  percentageStr ??= '0';
  return ((int.parse(sizeStr) ~/ (1024 * 1024)) *
          (int.parse(filterPercentage(percentageStr)) / 100))
      .toInt();
}

String getDownloadStatusLine(DownloadModel download) {
  return "${download.speed}/s - ${totalCompletedInMb(sizeStr: download.size, percentageStr: download.downloadProgress.toString())}/${totalSizeInMb(sizeStr: download.size)}MB";
}

void launchUrl(String url) async {
  if (await canLaunch(url))
    await launch(url);
  else
    throw 'Could not launch $url!';
}

Future<bool> getDeveloperMode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('developer_mode') ?? false;
}

Future<void> setDeveloperMode(bool enable) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('developer_mode', enable);
}

Future<bool> getDark() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('dark_theme') ?? false;
}

Future<void> setDark(bool dark) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('dark_theme', dark);
}

Widget ifUpdateWidget(Widget child, {bool flipCondition = false}) => Builder(
      builder: (context) {
        final downloadsLength =
            Provider.of<DownloadProvider>(context)?.downloads?.length ?? 0;
        return (flipCondition && downloadsLength <= 0) ||
                (!flipCondition && downloadsLength > 0)
            ? child
            : Container();
      },
    );
