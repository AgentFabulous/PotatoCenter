import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';

class BottomSheetContents extends StatefulWidget {
  @override
  _BottomSheetContentsState createState() => _BottomSheetContentsState();
}

class _BottomSheetContentsState extends State<BottomSheetContents> {
  int currentValue = 0;
  List<String> intervals = [
    'Never',
    'Once a day',
    'Once a week',
    'Once a month'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Update check interval"),
            FutureBuilder(
              initialData: 2,
              future: AndroidFlutterUpdater.getUpdateCheckSetting(),
              builder: (context, snapshot) => DropdownButton(
                    value: snapshot.data,
                    items: [0, 1, 2, 3].map((int val) {
                      return DropdownMenuItem(
                        value: val,
                        child: Text(intervals[val]),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        AndroidFlutterUpdater.setUpdateCheckSetting(v)
                            .then((v) => setState(() {})),
                  ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Mobile data warning"),
            FutureBuilder(
              initialData: true,
              future: AndroidFlutterUpdater.getWarn(),
              builder: (context, snapshot) {
                return Switch(
                    value: snapshot.data,
                    onChanged: (b) => AndroidFlutterUpdater.setWarn(b)
                        .then((v) => setState(() {})));
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Delete updates when installed"),
            FutureBuilder(
              initialData: false,
              future: AndroidFlutterUpdater.getAutoDelete(),
              builder: (context, snapshot) {
                return Switch(
                    value: snapshot.data,
                    onChanged: (b) => AndroidFlutterUpdater.setAutoDelete(b)
                        .then((v) => setState(() {})));
              },
            ),
          ],
        ),
        FutureBuilder(
          initialData: false,
          future: AndroidFlutterUpdater.isABDevice(),
          builder: (context, snapshot) => snapshot.data
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Install updates faster"),
                    FutureBuilder(
                      initialData: false,
                      future: AndroidFlutterUpdater.getPerformanceMode(),
                      builder: (context, snapshot) {
                        return Switch(
                            value: snapshot.data,
                            onChanged: (b) =>
                                AndroidFlutterUpdater.setPerformanceMode(b)
                                    .then((v) => setState(() {})));
                      },
                    ),
                  ],
                )
              : Container(),
        )
      ]),
    );
  }
}
