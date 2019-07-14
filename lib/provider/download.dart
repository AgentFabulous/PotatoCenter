import 'dart:async';

import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/foundation.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/models/download.dart';

class DownloadProvider extends ChangeNotifier {
  DownloadProvider() {
    loadData();
  }

  List<String> _downloadIds = List();
  String _lastChecked = 'Checking for updates';
  bool _isUpdateAvailable = false;

  StreamSubscription _streamSubscription;
  List<DownloadModel> downloads = List();

  List<String> get downloadIds => _downloadIds;

  String get lastChecked => _lastChecked;

  bool get isUpdateAvailable => _isUpdateAvailable;

  set downloadIds(List<String> val) {
    _downloadIds = val;
    notifyListeners();
  }

  set lastChecked(String val) {
    _lastChecked = val;
    notifyListeners();
  }

  set isUpdateAvailable(bool val) {
    _isUpdateAvailable = val;
    notifyListeners();
  }

  Future<void> loadData() async {
    downloads.clear();
    _streamSubscription = AndroidFlutterUpdater.registerStreamListener(
      streamSubscription: _streamSubscription,
      onData: (data) {
        if (data.split('~')[0] == 'update_available') {
          isUpdateAvailable = strToBool(data.split('~')[1]);
        }
      },
    );
    await AndroidFlutterUpdater.checkForUpdates();
    lastChecked = await AndroidFlutterUpdater.getLastChecked();
    downloadIds = await AndroidFlutterUpdater.getDownloads();
    populateDownloads();
  }

  populateDownloads() {
    downloads.clear();
    _downloadIds.forEach((id) => downloads
        .add(DownloadModel(id: id, notifyListenersCb: notifyListeners)));
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    downloads.forEach((download) => download.dispose());
    super.dispose();
  }
}
