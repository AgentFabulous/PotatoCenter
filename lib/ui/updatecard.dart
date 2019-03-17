import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:potato_center/internal/app_data.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/ui/common.dart';
import 'package:potato_center/ui/customprogressbar.dart';
import 'package:simple_permissions/simple_permissions.dart';

class StoragePermCard extends StatefulWidget {
  final TextStyle textStyle;
  final VoidCallback setStateCb;

  StoragePermCard({this.textStyle, this.setStateCb});

  @override
  _StoragePermCardState createState() => _StoragePermCardState();
}

class _StoragePermCardState extends State<StoragePermCard> {
  @override
  Widget build(BuildContext context) {
    return UpdateCard(
        contents: GestureDetector(
      onTap: () =>
          SimplePermissions.requestPermission(Permission.WriteExternalStorage)
              .then((v) => setState(() {
                    widget.setStateCb();
                  })),
      child: Text("No storage write permissions!", style: widget.textStyle),
    ));
  }
}

class UpdateCard extends StatefulWidget {
  final Widget contents;

  UpdateCard({@required this.contents});

  @override
  _UpdateCardState createState() => _UpdateCardState();
}

class _UpdateCardState extends State<UpdateCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0 * AppData().scaleFactorW),
      child: FutureBuilder(
          future: getLightTheme(),
          initialData: true,
          builder: (context, snapshot) {
            return Theme(
              data: snapshot.data ? AppData().appThemeDark : AppData().appTheme,
              child: Card(
                  color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15.0 * AppData().scaleFactorA),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.0 * AppData().scaleFactorA),
                    child: widget.contents,
                  )),
            );
          }),
    );
  }
}

class CardContents extends StatefulWidget {
  final int index;
  final TextStyle heading;
  final bool roundBoi;

  CardContents(
      {@required this.index, @required this.heading, @required this.roundBoi});

  @override
  _CardContentsState createState() => _CardContentsState();
}

class _CardContentsState extends State<CardContents> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    FutureBuilder(
                        future: AndroidFlutterUpdater.getVersion(
                            AppData().updateIds[widget.index]),
                        initialData: "0.0",
                        builder: (context, text) {
                          return Text(
                            "v${text.data}",
                            style: widget.heading,
                          );
                        }),
                  ],
                ),
                FutureBuilder(
                    future: AndroidFlutterUpdater.getTimestamp(
                        AppData().updateIds[widget.index]),
                    initialData: "Loading",
                    builder: (context, text) {
                      return Text(text.data);
                    }),
              ],
            ),
            ControlsRow(index: widget.index)
          ],
        ),
        ProgressWidget(roundBoi: widget.roundBoi)
      ],
    );
  }
}

class ProgressWidget extends StatefulWidget {
  final Key key = GlobalKey<_ProgressWidgetState>();
  final bool roundBoi;

  ProgressWidget({@required this.roundBoi});

  @override
  _ProgressWidgetState createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  @override
  void initState() {
    super.initState();
    registerCallback(widget.key, this.callback, critical: true);
  }

  @override
  void dispose() {
    unregisterCallback(widget.key);
    super.dispose();
  }

  void callback(Function fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        statusEnumCheck(UpdateStatus.STARTING) ||
                statusEnumCheck(UpdateStatus.DOWNLOADING) ||
                statusEnumCheck(UpdateStatus.PAUSED)
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: CustomProgressBar(
                    percentage: strToStatusEnum(
                                AppData().nativeData['update_status']) ==
                            UpdateStatus.STARTING
                        ? null
                        : double.parse(filterPercentage(
                            AppData().nativeData['percentage'].toString())),
                    negativeColor:
                        /*Color.fromRGBO(AppData.appColor.red,
                        AppData.appColor.green, AppData.appColor.blue, 0.9)*/
                        HSLColor.fromColor(AppData().appTheme.accentColor)
                            .withLightness(0.65)
                            .withSaturation(0.65)
                            .toColor(),
                    positiveColor: InheritedApp.of(context).data
                        ? AppData().appTheme.cardColor
                        : AppData().appThemeDark.cardColor,
                    roundBoi: widget.roundBoi,
                    thickness: 20.0 * AppData().scaleFactorH,
                    autoPad: true,
                  )),
                  strToStatusEnum(AppData().nativeData['update_status']) ==
                          UpdateStatus.STARTING
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(
                              left: 10.0 * AppData().scaleFactorW),
                          child: Text("${AppData().nativeData['percentage']}"),
                        )
                ],
              )
            : Container(),
        strToStatusEnum(AppData().nativeData['update_status']) ==
                UpdateStatus.UNKNOWN
            ? Container()
            : Text(strToStatusEnum(AppData().nativeData['update_status']) ==
                    UpdateStatus.DOWNLOADING
                ? "${AppData().nativeData['eta']} (${totalCompletedInMb()}MB of ${totalSizeInMb()}MB) "
                : statusCapitalize(
                    strToStatusEnum(AppData().nativeData['update_status'])
                        .toString()
                        .toLowerCase())),
      ],
    );
  }
}

class ControlsRow extends StatefulWidget {
  final int index;
  final Key key = GlobalKey<_ControlsRowState>();

  ControlsRow({@required this.index});

  @override
  _ControlsRowState createState() => _ControlsRowState();
}

class _ControlsRowState extends State<ControlsRow> {
  @override
  void initState() {
    super.initState();
    registerCallback(widget.key, this.callback, critical: true);
  }

  @override
  void dispose() {
    unregisterCallback(widget.key);
    super.dispose();
  }

  void callback(Function fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        !statusEnumCheck(UpdateStatus.UNKNOWN) &&
                !statusEnumCheck(UpdateStatus.DELETED) &&
                !statusEnumCheck(UpdateStatus.PAUSED_ERROR)
            ? Container()
            : IconButton(
                icon: Icon(Icons.file_download),
                onPressed: () {
                  AndroidFlutterUpdater.needsWarn().then((v) {
                    if (v)
                      popupMenuBuilder(
                          context,
                          AlertDialog(
                            title: Text("Warning!"),
                            content: Text(
                                "You appear to be on mobile data! Would you like to still continue?"),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text("No"),
                                  onPressed: () => Navigator.of(context).pop()),
                              FlatButton(
                                  child: Text("Yes"),
                                  onPressed: () {
                                    AndroidFlutterUpdater.startDownload(
                                        AppData().updateIds[widget.index]);
                                    Navigator.of(context).pop();
                                  }),
                            ],
                          ),
                          dismiss: true);
                    else
                      AndroidFlutterUpdater.startDownload(
                          AppData().updateIds[widget.index]);
                  });
                }),
        statusEnumCheck(UpdateStatus.DOWNLOADING) ||
                statusEnumCheck(UpdateStatus.PAUSED)
            ? Row(children: <Widget>[
                statusEnumCheck(UpdateStatus.PAUSED)
                    ? IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () => AndroidFlutterUpdater.resumeDownload(
                            AppData().updateIds[widget.index]))
                    : IconButton(
                        icon: Icon(Icons.pause),
                        onPressed: () => AndroidFlutterUpdater.pauseDownload(
                            AppData().updateIds[widget.index])),
              ])
            : Container(),
        !statusEnumCheck(UpdateStatus.UNKNOWN) &&
                !statusEnumCheck(UpdateStatus.DELETED) &&
                !statusEnumCheck(UpdateStatus.INSTALLING)
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () => AndroidFlutterUpdater.cancelAndDelete(
                    AppData().updateIds[widget.index]))
            : Container(),
        statusEnumCheck(UpdateStatus.DOWNLOADED)
            ? IconButton(
                onPressed: () => AndroidFlutterUpdater.verifyDownload(
                    AppData().updateIds[widget.index]),
                icon: Icon(Icons.search))
            : Container(),
        statusEnumCheck(UpdateStatus.VERIFIED)
            ? IconButton(
                onPressed: () => AndroidFlutterUpdater.installUpdate(
                    AppData().updateIds[widget.index]),
                icon: Icon(Icons.perm_device_information))
            : Container()
      ],
    );
  }
}
