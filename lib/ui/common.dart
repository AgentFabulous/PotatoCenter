import 'package:flutter/material.dart';

Future<void> popupMenuBuilder(BuildContext context, Widget child,
    {bool dismiss = false}) async {
  return showDialog(
      context: context,
      barrierDismissible: dismiss,
      builder: (BuildContext context) => child);
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class InheritedApp extends InheritedWidget {
  final dynamic data;

  InheritedApp({this.data, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedApp of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(InheritedApp);
}
