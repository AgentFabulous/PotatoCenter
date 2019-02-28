import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:potato_center/internal/methods.dart';

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
              future: AndroidFlutterUpdater.getWarn(),
              builder: (context, snapshot) {
                return Switch(
                    value: strToBool(snapshot.data.toString()),
                    onChanged: (b) => AndroidFlutterUpdater.setWarn(b));
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("Delete updates when installed"),
            FutureBuilder(
              future: AndroidFlutterUpdater.getAutoDelete(),
              builder: (context, snapshot) {
                return Switch(
                    value: strToBool(snapshot.data.toString()),
                    onChanged: (b) => AndroidFlutterUpdater.setAutoDelete(b));
              },
            ),
          ],
        )
      ]),
    );
  }
}
