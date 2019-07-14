import 'dart:async';

import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/foundation.dart';

class DownloadModel {
  final String id;
  final VoidCallback notifyListenersCb;

  String name = '';
  String version = '';
  String timestamp = '';
  int downloadProgress = 0;
  UpdateStatus status = UpdateStatus.UNKNOWN;
  int persistentStatus = 0;
  String eta = '';
  String speed = '';
  String size = '';
  String releaseType = '';
  StreamSubscription _streamSubscription;

  DownloadModel({@required this.id, this.notifyListenersCb})
      : assert(id != null) {
    init();
  }

  Future<void> init() async {
    name = await AndroidFlutterUpdater.getName(id);
    version = await AndroidFlutterUpdater.getVersion(id);
    timestamp = await AndroidFlutterUpdater.getTimestamp(id);
    downloadProgress = await AndroidFlutterUpdater.getDownloadProgress(id);
    status = await AndroidFlutterUpdater.getStatus(id);
    persistentStatus = await AndroidFlutterUpdater.getPersistentStatus(id);
    eta = await AndroidFlutterUpdater.getEta(id);
    speed = await AndroidFlutterUpdater.getSpeed(id);
    size = await AndroidFlutterUpdater.getSize(id);
    releaseType = await AndroidFlutterUpdater.getReleaseType();
    _streamSubscription = AndroidFlutterUpdater.registerStreamListener(
        streamSubscription: _streamSubscription,
        onData: (data) {
          if (data.split('~')[0] == id) {
            downloadProgress = double.parse(data.split('~')[1]).toInt();
            if (downloadProgress != -1) {
              getSpeed();
              getEta();
              getStatus();
              getPersistentStatus();
            } else {
              downloadProgress = 0;
            }
          }
        });
    notifyListenersCb();
  }

  void dispose() => _streamSubscription?.cancel();

  Future<void> startDownload() async {
    await AndroidFlutterUpdater.startDownload(id);
    notifyListenersCb();
  }

  Future<void> pauseDownload() async {
    await AndroidFlutterUpdater.pauseDownload(id);
    notifyListenersCb();
  }

  Future<void> resumeDownload() async {
    await AndroidFlutterUpdater.resumeDownload(id);
    notifyListenersCb();
  }

  Future<void> verifyDownload() async {
    await AndroidFlutterUpdater.verifyDownload(id);
    notifyListenersCb();
  }

  Future<void> startUpdate() async {
    await AndroidFlutterUpdater.startUpdate(id);
    notifyListenersCb();
  }

  Future<void> cancelAndDelete() async {
    await AndroidFlutterUpdater.cancelAndDelete(id);
    notifyListenersCb();
  }

  Future<void> installUpdate() async {
    await AndroidFlutterUpdater.installUpdate(id);
    notifyListenersCb();
  }

  Future<void> getName() async {
    name = await AndroidFlutterUpdater.getName(id);
    notifyListenersCb();
  }

  Future<void> getVersion() async {
    version = await AndroidFlutterUpdater.getVersion(id);
    notifyListenersCb();
  }

  Future<void> getTimestamp() async {
    timestamp = await AndroidFlutterUpdater.getTimestamp(id);
    notifyListenersCb();
  }

  Future<void> getDownloadProgress() async {
    downloadProgress = await AndroidFlutterUpdater.getDownloadProgress(id);
    notifyListenersCb();
  }

  Future<void> getStatus() async {
    status = await AndroidFlutterUpdater.getStatus(id);
    notifyListenersCb();
  }

  Future<void> getPersistentStatus() async {
    persistentStatus = await AndroidFlutterUpdater.getPersistentStatus(id);
    notifyListenersCb();
  }

  Future<void> getEta() async {
    eta = await AndroidFlutterUpdater.getEta(id);
    notifyListenersCb();
  }

  Future<void> getSpeed() async {
    speed = await AndroidFlutterUpdater.getSpeed(id);
    notifyListenersCb();
  }

  Future<void> getSize() async {
    size = await AndroidFlutterUpdater.getSize(id);
    notifyListenersCb();
  }

  Future<void> getReleaseType() async {
    releaseType = await AndroidFlutterUpdater.getReleaseType();
    notifyListenersCb();
  }
}
