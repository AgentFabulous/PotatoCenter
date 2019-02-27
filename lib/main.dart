import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

import 'internal/app_data.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData.dark(),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/app': (BuildContext context) => MyApp()
      },
    ));

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
    super.initState();
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
              child: CircleAvatar(
                  radius: 100.0 * AppData().scaleFactorW,
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset("assets/app-logo.svg",
                      fit: BoxFit.fitWidth,
                      width: 150.0 * AppData().scaleFactorW)),
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 75.0,
              left: 20.0,
              child: new AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: 0.05,
                child: new ClipPath(
                    child: Text("Updater",
                        style: TextStyle(
                            fontSize: AppData().scaleFactorH * 90.0))),
              ),
            ),
            Positioned(
              bottom: AppData().scaleFactorH * 30.0,
              left: AppData().scaleFactorW * 30.0,
              child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  opacity: 0.05,
                  child: Container(
                      height: AppData().scaleFactorH * 30.0,
                      child: Image.asset("posp.png"))),
            ),
          ],
        ));
  }
}
