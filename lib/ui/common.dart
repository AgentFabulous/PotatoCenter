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
