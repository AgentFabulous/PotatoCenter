import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:simple_permissions/simple_permissions.dart';

import 'internal/app_data.dart';
import 'internal/methods.dart';
import 'ui/bottomsheet.dart';
import 'ui/common.dart';
import 'ui/customprogressbar.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) => runApp(StreamBuilder(
      initialData: false,
      stream: AppData().lightThemeEnabled,
      builder: (context, snapshot) {
        return MaterialApp(
          theme: snapshot.data ? AppData().appTheme : AppData().appThemeDark,
          home: SplashScreen(),
          routes: <String, WidgetBuilder>{
            '/app': (BuildContext context) => MyApp()
          },
        );
      })));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacityLogo = 1.0;
  double opacityBg = 1.0;
  double opacityIcon = 0.0;

  Future<void> pushAndReplace(String routeName) async {
    final current = ModalRoute.of(context);
    Navigator.pushNamed(context, routeName);
    await Future.delayed(Duration(milliseconds: 1000));
    Navigator.removeRoute(context, current);
  }

  @override
  void initState() {
    // Set theme before we do anything
    getLightTheme().then((b) => AppData().setLight(b));

    super.initState();

    // Sync with native status
    AndroidFlutterUpdater.checkForUpdates().then((v) {
      AndroidFlutterUpdater.getNativeStatus()
          .then((nativeMap) => AppData().nativeData = nativeMap);
      AndroidFlutterUpdater.getDownloads().then((v) {
        AppData().updateIds = v;
        triggerCallbacks(AppData().nativeData, force: true);
      });
    });
    AndroidFlutterUpdater.registerStreamListener(
        subscription: AppData().streamSubscription, fn: triggerCallbacks);
    AndroidFlutterUpdater.getNativeStatus().then((nativeMap) {
      AppData().nativeData = nativeMap;
    });

    handleAdvancedMode();

    Duration sD = new Duration(milliseconds: 500);
    Duration mD = new Duration(seconds: 1);
    Duration lD = new Duration(seconds: 3);
    Future.delayed(sD, () => setState(() => opacityLogo = 1.0)).then((v) {
      Future.delayed(mD, () => setState(() => opacityLogo = 0.0)).then((v) {
        Future.delayed(sD, () => setState(() => opacityIcon = 1.0)).then((v) {
          Future.delayed(lD, () => setState(() => opacityIcon = 0.0)).then((v) {
            Future.delayed(
                sD,
                () => Navigator.of(context).pushReplacement(PageTransition(
                    curve: Curves.easeInOut,
                    duration: Duration(seconds: 2),
                    child: MyApp(),
                    type: PageTransitionType.fade)));
          });
        });
      });
    });
    Future.delayed(
        Duration(milliseconds: 500), () => setState(() => opacityBg = 0.0));
  }

  @override
  Widget build(BuildContext context) {
    // Make our life a bit easier.
    AppData().scaleFactorH = MediaQuery.of(context).size.height / 900;
    AppData().scaleFactorW = MediaQuery.of(context).size.width / 450;
    AppData().scaleFactorA = (MediaQuery.of(context).size.width *
            MediaQuery.of(context).size.height) /
        (900 * 450);
    return Scaffold(
      appBar: null,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedOpacity(
            duration: Duration(seconds: 2),
            opacity: opacityBg,
            curve: Curves.easeInOut,
            child: Container(
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                      colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
                      begin: FractionalOffset.topRight,
                      end: FractionalOffset.bottomLeft,
                      tileMode: TileMode.clamp)),
            ),
          ),
          AnimatedOpacity(
              opacity: opacityLogo,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 300),
              child: Image.asset(
                "assets/posp.png",
                scale: 2 * AppData().scaleFactorW,
              )),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: opacityIcon,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 300),
              child: Card(
                color: Colors.white,
                elevation: 7.5,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(100.0 * AppData().scaleFactorW)),
                child: CircleAvatar(
                    radius: 100.0 * AppData().scaleFactorW,
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset("assets/app-logo.svg",
                        fit: BoxFit.fitWidth,
                        width: 150.0 * AppData().scaleFactorW)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final Key key = GlobalKey<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentValue = 0;
  bool roundBoi = false;
  List<String> intervals = [
    'Never',
    'Once a day',
    'Once a week',
    'Once a month'
  ];

  @override
  void initState() {
    super.initState();
    registerCallback(widget.key, this.callback, critical: false);
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
    return Scaffold(
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              AndroidFlutterUpdater.checkForUpdates().then((v) =>
                  AndroidFlutterUpdater.getDownloads()
                      .then((v) => setState(() => AppData().updateIds = v)));
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("Checking for updates")));
            },
            child: Icon(Icons.refresh, color: Theme.of(context).cardColor),
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Builder(
                builder: (context) => IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => BottomSheetContents());
                      },
                      icon: Icon(Icons.keyboard_arrow_up),
                    ),
              ),
              FutureBuilder(
                initialData: false,
                future: getAdvancedMode(),
                builder: (context, snapshot) => snapshot.data
                    ? IconButton(
                        onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (context) =>
                                AdvancedBottomSheetContents()),
                        icon: Icon(Icons.settings),
                      )
                    : Container(height: 0),
              ),
              FutureBuilder(
                initialData: true,
                future: getLightTheme(),
                builder: (context, snapshot) => AnimatedCrossFade(
                    firstChild: IconButton(
                        icon: Icon(Icons.brightness_medium),
                        onPressed: () => setLightTheme(false)),
                    secondChild: IconButton(
                        icon: Icon(Icons.brightness_4),
                        onPressed: () => setLightTheme(true)),
                    crossFadeState: snapshot.data
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: Duration(milliseconds: 300)),
              )
            ],
          ),
        ),
        appBar: null,
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 75.0 * AppData().scaleFactorH,
              left: 20.0 * AppData().scaleFactorW,
              child: GestureDetector(
                onLongPress: () => setState(() => roundBoi = !roundBoi),
                child: new AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity:
                      strToBool(AppData().nativeData['update_available']) ||
                              (AppData().updateIds != null &&
                                  AppData().updateIds.length > 0)
                          ? 1.0
                          : 0.05,
                  child: new ClipPath(
                      child: Text(
                          strToBool(AppData().nativeData['update_available']) ||
                                  (AppData().updateIds != null &&
                                      AppData().updateIds.length > 0)
                              ? "Update\navailable!"
                              : "Up to date.",
                          style: TextStyle(
                              fontSize: AppData().scaleFactorH * 70.0,
                              color: strToBool(AppData()
                                          .nativeData['update_available']) ||
                                      (AppData().updateIds != null &&
                                          AppData().updateIds.length > 0)
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context).textTheme.title.color))),
                ),
              ),
            ),
            Positioned(
              bottom: AppData().scaleFactorH * 30.0,
              left: AppData().scaleFactorW * 30.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => handleAdvancedMode(),
                    onLongPress: () {
                      setAdvancedMode(false).then(
                          (_) => setState(() => AppData().advancedMode = 0));
                    },
                    child: AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        opacity: 0.05,
                        child: Container(
                            height: AppData().scaleFactorH * 30.0,
                            child: ImageIcon(AssetImage("posp.png"),
                                size: AppData().scaleFactorH * 100.0))),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              top: 0,
              right: 0,
              left: 0,
              child: Align(
                alignment: Alignment.center,
                child: ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: BodyCards(roundBoi: roundBoi)),
              ),
            )
          ],
        ));
  }
}

class BodyCards extends StatefulWidget {
  final bool roundBoi;
  final Key key = GlobalKey<_BodyCardsState>();

  BodyCards({this.roundBoi = false});

  @override
  _BodyCardsState createState() => _BodyCardsState();
}

class _BodyCardsState extends State<BodyCards> {
  TextStyle heading = TextStyle(fontSize: 30.0 * AppData().scaleFactorH);

  @override
  void initState() {
    super.initState();
    registerCallback(widget.key, this.callback, critical: false);
    Future.delayed(
        Duration.zero,
        () => heading = TextStyle(
            fontSize: 30.0 * AppData().scaleFactorH,
            color: Theme.of(context).cardColor)).then((_) => setState(() {}));
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
  Widget build(BuildContext _context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 8.0 * AppData().scaleFactorW),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15.0 * AppData().scaleFactorA),
              ),
              child: Padding(
                padding: EdgeInsets.all(15.0 * AppData().scaleFactorH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Current build",
                      style: heading.copyWith(
                          color: Theme.of(context).accentColor),
                    ),
                    Row(
                      children: <Widget>[
                        FutureBuilder(
                            initialData: "0.0",
                            future: AndroidFlutterUpdater.getBuildVersion(),
                            builder: (context, snapshot) =>
                                Text("v${snapshot.data}")),
                        FutureBuilder(
                            initialData: "...",
                            future:
                                AndroidFlutterUpdater.getProp("ro.potato.dish"),
                            builder: (context, snapshot) =>
                                Text(" - ${snapshot.data}")),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        FutureBuilder(
                            initialData: "...",
                            future: AndroidFlutterUpdater.getModel(),
                            builder: (context, snapshot) =>
                                Text("${snapshot.data}")),
                        FutureBuilder(
                            initialData: "...",
                            future: AndroidFlutterUpdater.getDeviceName(),
                            builder: (context, snapshot) =>
                                Text(" - (${snapshot.data})")),
                      ],
                    ),
                    FutureBuilder(
                        initialData: "...",
                        future: AndroidFlutterUpdater.getBuildDate(),
                        builder: (context, snapshot) =>
                            Text("${snapshot.data}")),
                  ],
                ),
              ),
            )),
        MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount:
                  AppData().updateIds == null ? 0 : AppData().updateIds.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.0 * AppData().scaleFactorW),
                  child: FutureBuilder(
                      future: getLightTheme(),
                      initialData: true,
                      builder: (context, snapshot) {
                        return Theme(
                          data: snapshot.data
                              ? AppData().appThemeDark
                              : AppData().appTheme,
                          child: Card(
                              color: Theme.of(_context).accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15.0 * AppData().scaleFactorA),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                    15.0 * AppData().scaleFactorA),
                                child: CardContents(
                                    index: index,
                                    heading: heading,
                                    roundBoi: widget.roundBoi),
                              )),
                        );
                      }),
                );
              }),
        ),
      ],
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
    return FutureBuilder(
      initialData: PermissionStatus.authorized,
      future: SimplePermissions.getPermissionStatus(
          Permission.WriteExternalStorage),
      builder: (context, snapshot) => (snapshot.data as PermissionStatus) !=
              PermissionStatus.authorized
          ? GestureDetector(
              onTap: () => SimplePermissions.requestPermission(
                      Permission.WriteExternalStorage)
                  .then((v) => setState(() {})),
              child:
                  Text("No storage write permissions!", style: widget.heading),
            )
          : Column(
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
            ),
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
                    positiveColor: Color.fromRGBO(AppData.appColor.red,
                        AppData.appColor.green, AppData.appColor.blue, 0.9),
                    negativeColor: Theme.of(context).backgroundColor,
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
