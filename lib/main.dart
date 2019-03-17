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
import 'ui/updatecard.dart';

void main() {
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(StreamBuilder(
          initialData: false,
          stream: AppData().lightThemeEnabled,
          builder: (context, snapshot) => InheritedApp(
                child: MaterialApp(
                  theme: snapshot.data
                      ? AppData().appTheme
                      : AppData().appThemeDark,
                  home: SplashScreen(),
                  routes: <String, WidgetBuilder>{
                    '/app': (BuildContext context) => MyApp()
                  },
                ),
                data: snapshot.data,
              ))));
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
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20.0 * AppData().scaleFactorW,
                        top: 75 * AppData().scaleFactorH),
                    child: GestureDetector(
                      onLongPress: () => setState(() => roundBoi = !roundBoi),
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: strToBool(
                                    AppData().nativeData['update_available']) ||
                                (AppData().updateIds != null &&
                                    AppData().updateIds.length > 0)
                            ? 1.0
                            : 0.05,
                        child: Text(
                            strToBool(AppData()
                                        .nativeData['update_available']) ||
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
                                    : Theme.of(context).textTheme.title.color)),
                      ),
                    ),
                  ),
                  ScrollConfiguration(
                      behavior: NoGlowScrollBehavior(),
                      child: BodyCards(roundBoi: roundBoi))
                ],
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
            /*Positioned(
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
            )*/
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
    return Expanded(
      child: Center(
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              DeviceInfoCard(textStyle: heading),
              FutureBuilder(
                  initialData: PermissionStatus.authorized,
                  future: SimplePermissions.getPermissionStatus(
                      Permission.WriteExternalStorage),
                  builder: (context, snapshot) => (snapshot.data
                              as PermissionStatus) !=
                          PermissionStatus.authorized
                      ? StoragePermCard(
                          textStyle: heading,
                          setStateCb: () => setState(() {}),
                        )
                      : MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: AppData().updateIds == null ||
                                  AppData().updateIds.length == 0
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0 * AppData().scaleFactorH),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Opacity(
                                          opacity: 0.5,
                                          child: Text("No updates here",
                                              style: TextStyle(
                                                  fontSize: 20.0 *
                                                      AppData().scaleFactorH))),
                                      Text(" 🤷🏻‍♀️",
                                          style: TextStyle(
                                              fontSize: 20.0 *
                                                  AppData().scaleFactorH)),
                                    ],
                                  ))
                              : ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: AppData().updateIds.length,
                                  itemBuilder: (context, index) {
                                    return UpdateCard(
                                      contents: CardContents(
                                          index: index,
                                          heading: heading,
                                          roundBoi: widget.roundBoi),
                                    );
                                  }))),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
