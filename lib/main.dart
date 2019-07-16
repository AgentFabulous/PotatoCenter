import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/models/download.dart';
import 'package:potato_center/provider/app_info.dart';
import 'package:potato_center/provider/download.dart';
import 'package:potato_center/provider/sheet_data.dart';
import 'package:potato_center/ui/bottom_sheet.dart';
import 'package:potato_center/ui/custom_bottom_sheet.dart';
import 'package:potato_center/ui/custom_icons.dart';
import 'package:potato_center/ui/no_glow_scroll_behavior.dart';
import 'package:provider/provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'provider/current_build.dart';

BorderRadius _kBorderRadius = BorderRadius.circular(12);

void main() => runApp(PotatoCenterRoot());

class PotatoCenterRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrentBuildProvider>.value(
          value: CurrentBuildProvider(),
        ),
        ChangeNotifierProvider<AppInfoProvider>.value(
          value: AppInfoProvider(),
        ),
        ChangeNotifierProvider<SheetDataProvider>.value(
          value: SheetDataProvider(),
        ),
        ChangeNotifierProvider<DownloadProvider>.value(
          value: DownloadProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final appInfo = Provider.of<AppInfoProvider>(context);
          return MaterialApp(
            builder: (context, child) => ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: child,
            ),
            debugShowCheckedModeBanner: false,
            theme: appInfo.isDark
                ? ThemeData.dark().copyWith(accentColor: appInfo.accentColor)
                : ThemeData.light().copyWith(accentColor: appInfo.accentColor),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appInfo = Provider.of<AppInfoProvider>(context);
    if (appInfo.splashMode == 0) {
      Future.delayed(Duration(seconds: 1), () => appInfo.splashMode = 1);
      Future.delayed(Duration(seconds: 2), () => appInfo.splashMode = 2);
    }
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          appBar: null,
          body: Stack(
            children: <Widget>[
              Positioned(
                bottom: 24,
                left: 24,
                child: SizedBox(
                  child: Icon(
                    Logo.posp_logo,
                    size: 28,
                    color: Theme.of(context).iconTheme.color.withOpacity(0.05),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: EdgeInsets.only(
                        top: 32.0,
                        bottom: 32.0 + _paddingForLogo(constraints),
                      ),
                      child: SizedBox(
                        height: constraints.maxHeight <= 610
                            ? constraints.maxHeight
                            : constraints.maxHeight -
                                (64 + _paddingForLogo(constraints)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            _updateHeaderText,
                            _homeCards,
                            Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: _floatingActionButton,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _bottomAppBar,
        ),
        Visibility(
          visible: appInfo.splashMode != 2,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: null,
            body: Stack(
              children: <Widget>[
                AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: appInfo.splashMode == 0 ? 1 : 0,
                  curve: Curves.easeInOut,
                  child: Container(
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                        colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                        begin: FractionalOffset.topRight,
                        end: FractionalOffset.bottomLeft,
                        tileMode: TileMode.clamp,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                      opacity: appInfo.splashMode == 0 ? 1 : 0,
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 300),
                      child: Image.asset(
                        "assets/posp.png",
                        scale: 1.75,
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _paddingForLogo(constraints) => constraints.maxHeight <= 610 ? 12 : 0;

  Widget get _homeCards => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ifUpdateWidget(SizedBox(height: 120, child: _updatesList)),
          _paddedChild(ifUpdateWidget(_changelogCard())),
          _paddedChild(ifUpdateWidget(_divider)),
          _paddedChild(_currentBuildCard()),
          _paddedChild(ifUpdateWidget(
            _noUpdatesText,
            flipCondition: true,
          )),
        ],
      );

  Widget _paddedChild(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: child,
      );

  get _noUpdatesText => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Opacity(
              opacity: 0.5,
              child: Text("No updates here", style: TextStyle(fontSize: 20.0)),
            ),
            Text(" 🤷🏻‍♀️", style: TextStyle(fontSize: 20.0)),
          ],
        ),
      );

  get _updateHeaderText => Builder(
        builder: (context) {
          final downloadProvider = Provider.of<DownloadProvider>(context);
          return Padding(
            padding: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                opacity: downloadProvider.downloads.length > 0 &&
                        downloadProvider.isUpdateAvailable
                    ? 1.0
                    : 0.25,
                child: Text(
                  downloadProvider.downloads.length > 0 &&
                          downloadProvider.isUpdateAvailable
                      ? 'Update\navailable!'
                      : 'Up to date.',
                  style: TextStyle(fontSize: 64),
                ),
              ),
            ),
          );
        },
      );

  Widget get _divider => Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Container(
              height: 5,
              width: 175,
              decoration: BoxDecoration(
                color: HSLColor.fromColor(Theme.of(context).accentColor)
                    .withLightness(0.85)
                    .toColor(),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      );

  get _updatesList => Builder(
        builder: (context) {
          final downloadProvider = Provider.of<DownloadProvider>(context);
          return PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: downloadProvider.downloads.length,
            itemBuilder: (context, index) =>
                _paddedChild(_buildInfoCard(downloadProvider.downloads[index])),
          );
        },
      );

  Widget _buildInfoCard(DownloadModel download) => Builder(
        builder: (context) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
          color: HSLColor.fromColor(Theme.of(context).accentColor)
              .withLightness(0.85)
              .toColor(),
          child: DefaultTextStyle(
            style: TextStyle(
                color: HSLColor.fromColor(Theme.of(context).accentColor)
                    .withLightness(0.4)
                    .toColor()),
            child: IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                    color: HSLColor.fromColor(Theme.of(context).accentColor)
                        .withLightness(0.4)
                        .toColor(),
                  ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Hack, this can be improved.
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'New build',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Text(
                              '• Version - ${download.version} (${download.releaseType})'),
                          Text('• Date - ${download.timestamp}'),
                          Text(
                              '• Status - ${download.status == UpdateStatus.UNKNOWN ? 'Available' : formatStatus(download.status.toString())}'),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _downloadStatusRow(download),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _downloadStatusRow(DownloadModel download) => Builder(
        builder: (context) {
          final Color foregroundColor =
              HSLColor.fromColor(Theme.of(context).accentColor)
                  .withLightness(0.4)
                  .toColor();
          double iconSize = 20;

          final appInfo = Provider.of<AppInfoProvider>(context);
          return IconTheme(
            data: Theme.of(context)
                .iconTheme
                .copyWith(size: iconSize, color: foregroundColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: download.status != UpdateStatus.DELETED &&
                      download.status != UpdateStatus.INSTALLING &&
                      download.status != UpdateStatus.UNKNOWN &&
                      download.status != UpdateStatus.STARTING,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.close),
                    ),
                    onTap: () => download.cancelAndDelete(),
                  ),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.DOWNLOADING ||
                      download.status == UpdateStatus.PAUSED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(download.status == UpdateStatus.PAUSED
                          ? Icons.play_arrow
                          : Icons.pause),
                    ),
                    onTap: () => download.status == UpdateStatus.PAUSED
                        ? download.resumeDownload()
                        : download.pauseDownload(),
                  ),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.DOWNLOADING ||
                      download.status == UpdateStatus.PAUSED ||
                      download.status == UpdateStatus.STARTING,
                  child: _downloadProgressIndicator(download),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.DOWNLOADED ||
                      download.status == UpdateStatus.VERIFICATION_FAILED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.vpn_key),
                    ),
                    onTap: () => download.verifyDownload(),
                  ),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.VERIFIED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.perm_device_information),
                    ),
                    onTap: () {
                      final buttonTextColor =
                          HSLColor.fromColor(Theme.of(context).accentColor)
                              .withLightness(0.4)
                              .toColor();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Install Update'),
                          shape: RoundedRectangleBorder(
                            borderRadius: _kBorderRadius,
                          ),
                          content: Text(
                              'This operation will install the update. Continue?'),
                          actions: <Widget>[
                            FlatButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(color: buttonTextColor),
                                ),
                                onPressed: () => Navigator.of(context).pop()),
                            FlatButton(
                              child: Text(
                                'Yes',
                                style: TextStyle(color: buttonTextColor),
                              ),
                              onPressed: () {
                                download.installUpdate();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: download.status != UpdateStatus.DOWNLOADING &&
                      download.status != UpdateStatus.DOWNLOADED &&
                      download.status != UpdateStatus.STARTING &&
                      download.status != UpdateStatus.VERIFYING &&
                      download.status != UpdateStatus.VERIFIED &&
                      download.status != UpdateStatus.INSTALLING &&
                      download.status != UpdateStatus.INSTALLED &&
                      download.status != UpdateStatus.PAUSED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        appInfo.storageStatus == PermissionStatus.authorized
                            ? Icons.file_download
                            : Icons.warning,
                      ),
                    ),
                    onTap: () async {
                      if (appInfo.storageStatus !=
                          PermissionStatus.authorized) {
                        appInfo.storageStatus =
                            await SimplePermissions.requestPermission(
                          Permission.WriteExternalStorage,
                        );
                        if (appInfo.storageStatus !=
                            PermissionStatus.authorized) return;
                      }
                      final buttonTextColor =
                          HSLColor.fromColor(Theme.of(context).accentColor)
                              .withLightness(0.4)
                              .toColor();
                      await AndroidFlutterUpdater.needsWarn()
                          ? showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Warning!"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: _kBorderRadius,
                                ),
                                content: Text(
                                    "You appear to be on mobile data! Would you like to still continue?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "No",
                                      style: TextStyle(color: buttonTextColor),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(color: buttonTextColor),
                                    ),
                                    onPressed: () {
                                      download.startDownload();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            )
                          : download.startDownload();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _downloadProgressIndicator(DownloadModel download) => Builder(
        builder: (context) {
          final Color foregroundColor =
              HSLColor.fromColor(Theme.of(context).accentColor)
                  .withLightness(0.4)
                  .toColor();
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 0,
                    bottom: 0,
                    left: 0,
                    top: 0,
                    child: Center(
                      child: Text(
                        download.downloadProgress <= 0
                            ? 0.toString()
                            : download.downloadProgress.toString(),
                      ),
                    ),
                  ),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                    strokeWidth: 2.5,
                    value: download.downloadProgress <= 0 ||
                            download.status == UpdateStatus.STARTING
                        ? null
                        : download.downloadProgress / 100.0,
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget _changelogCard() => Builder(
        builder: (context) {
          final _foregroundColor =
              DefaultTextStyle.of(context).style.color.withOpacity(0.5);
          return Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).dividerColor
                : Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
            child: DefaultTextStyle(
              style: TextStyle(color: _foregroundColor),
              child: IconTheme(
                data: Theme.of(context)
                    .iconTheme
                    .copyWith(color: _foregroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Changelog & notes'),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () =>
                              launchUrl("https://potatoproject.co/changelog"),
                          child: Icon(
                            Icons.code,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget get _floatingActionButton => Builder(
        builder: (context) => FloatingActionButton(
          elevation: 0,
          backgroundColor: HSLColor.fromColor(Theme.of(context).accentColor)
              .withLightness(0.85)
              .toColor(),
          child: Icon(
            Icons.refresh,
            color: HSLColor.fromColor(Theme.of(context).accentColor)
                .withLightness(0.4)
                .toColor(),
          ),
          onPressed: () async =>
              await Provider.of<DownloadProvider>(context).loadData(),
        ),
      );

  Widget _currentBuildCard() => Builder(
        builder: (context) {
          final currentBuild = Provider.of<CurrentBuildProvider>(context);
          return Card(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).dividerColor
                : Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Current build',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  Text(
                      '• Version - ${currentBuild.version} | ${currentBuild.type}'),
                  Text(
                      '• Device - ${currentBuild.device} | ${currentBuild.codename}'),
                  Text('• Date - ${currentBuild.date}'),
                ],
              ),
            ),
          );
        },
      );

  Widget get _bottomAppBar => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: _kBorderRadius.topLeft,
          topRight: _kBorderRadius.topRight,
        ),
        child: Builder(
          builder: (context) {
            final appInfo = Provider.of<AppInfoProvider>(context);
            final sheetData = Provider.of<SheetDataProvider>(context);
            return BottomAppBar(
              color: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              shape: CircularNotchedRectangle(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.fastfood),
                      onPressed: () => AndroidFlutterUpdater.startActivity(
                        pkg: 'com.android.settings',
                        cls:
                            'com.android.settings.Settings\$FriesDashboardActivity',
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () =>
                          launchUrl("https://potatoproject.co/team"),
                    ),
                    Spacer(flex: 4),
                    AnimatedCrossFade(
                      firstChild: IconButton(
                          icon: Icon(Icons.brightness_medium),
                          onPressed: () => appInfo.isDark = true),
                      secondChild: IconButton(
                          icon: Icon(Icons.brightness_4),
                          onPressed: () => appInfo.isDark = false),
                      crossFadeState: !appInfo.isDark
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                    ),
                    Spacer(),
                    GestureDetector(
                      onLongPress: () {
                        if (appInfo.isDeveloper) {
                          if (!sheetData.isHandleVisible)
                            sheetData.isHandleVisible = true;
                          showModalBottomSheetApp(
                            dismissOnTap: false,
                            context: context,
                            builder: (context) =>
                                DeveloperBottomSheetContents(),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                          );
                        }
                      },
                      child: IconButton(
                        icon: Icon(
                          appInfo.isDeveloper
                              ? Icons.bug_report
                              : Icons.keyboard_arrow_up,
                        ),
                        onPressed: () {
                          if (!sheetData.isHandleVisible)
                            sheetData.isHandleVisible = true;
                          showModalBottomSheetApp(
                            dismissOnTap: false,
                            context: context,
                            builder: (context) => BottomSheetContents(),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
