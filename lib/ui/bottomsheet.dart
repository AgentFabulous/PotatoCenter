import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/ui/common.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(children: <Widget>[
          ListTile(
            title: Text("Update check interval"),
            trailing: FutureBuilder(
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
          ),
          ListTile(
            title: Text("Mobile data warning"),
            trailing: FutureBuilder(
              initialData: true,
              future: AndroidFlutterUpdater.getWarn(),
              builder: (context, snapshot) {
                return Switch(
                    value: snapshot.data,
                    onChanged: (b) => AndroidFlutterUpdater.setWarn(b)
                        .then((v) => setState(() {})));
              },
            ),
          ),
          ListTile(
            title: Text("Delete updates when installed"),
            trailing: FutureBuilder(
              initialData: false,
              future: AndroidFlutterUpdater.getAutoDelete(),
              builder: (context, snapshot) {
                return Switch(
                    value: snapshot.data,
                    onChanged: (b) => AndroidFlutterUpdater.setAutoDelete(b)
                        .then((v) => setState(() {})));
              },
            ),
          ),
          FutureBuilder(
            initialData: false,
            future: AndroidFlutterUpdater.isABDevice(),
            builder: (context, snapshot) => snapshot.data
                ? ListTile(
                    title: Text("Install updates faster"),
                    trailing: FutureBuilder(
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
                  )
                : Container(),
          ),
        ]),
        Divider(),
        ListTile(
          onTap: () => launchUrl("https://potatoproject.co/changelog"),
          title: Text("Changelog"),
          trailing: Icon(Icons.code),
        ),
        ListTile(
          onTap: () => launchUrl("https://potatoproject.co"),
          title: Text("Website"),
          trailing: Icon(Icons.public),
        ),
        ListTile(
          onTap: () => launchUrl("https://twitter.com/PotatoAndroid"),
          title: Text("Twitter"),
          trailing: Icon(MdiIcons.twitter),
        ),
        ListTile(
          onTap: () => launchUrl("https://t.me/SaucyPotatoesOfficial"),
          title: Text("Telegram"),
          trailing: Icon(MdiIcons.telegram),
        )
      ],
    );
  }
}

class AdvancedBottomSheetContents extends StatefulWidget {
  @override
  _AdvancedBottomSheetContentsState createState() =>
      _AdvancedBottomSheetContentsState();
}

class _AdvancedBottomSheetContentsState
    extends State<AdvancedBottomSheetContents> {
  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    registerCallback(key, this.callback, critical: true);
  }

  @override
  void dispose() {
    unregisterCallback(key);
    super.dispose();
  }

  void callback(Function fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Column(children: <Widget>[
          FutureBuilder(
            key: key,
            initialData: "Loading...",
            future: AndroidFlutterUpdater.getReleaseType(),
            builder: (context, snapshot) => ListTile(
                title: Text("Update channel"),
                subtitle: Text("Current: ${snapshot.data}"),
                trailing: RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () => popupMenuBuilder(
                        context, ChannelSelector(), dismiss: true),
                    child: Text("Change",
                        style: TextStyle(color: Theme.of(context).cardColor)))),
          ),
          ListTile(
            title: Text("Build verification"),
            trailing: FutureBuilder(
              initialData: true,
              future: AndroidFlutterUpdater.getVerify(),
              builder: (context, snapshot) {
                return Switch(
                    value: snapshot.data,
                    onChanged: (b) => AndroidFlutterUpdater.setVerify(b)
                        .then((v) => setState(() {})));
              },
            ),
          ),
        ]),
      ],
    );
  }
}

class ChannelSelector extends StatefulWidget {
  @override
  _ChannelSelectorState createState() => _ChannelSelectorState();
}

class _ChannelSelectorState extends State<ChannelSelector> {
  final _formKey = GlobalKey<FormState>();
  String _channel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Update channel"),
      content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Form(
          key: _formKey,
          child: TextFormField(
            decoration: InputDecoration(hintText: "Channel name"),
            validator: (value) {
              if (value.isEmpty)
                return "Please enter a channel name";
              else
                _channel = value;
            },
          ),
        )
      ]),
      actions: <Widget>[
        FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel")),
        FlatButton(
            onPressed: () {
              AndroidFlutterUpdater.setReleaseType("__default__");
              Navigator.of(context).pop();
            },
            child: Text("Reset")),
        FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                AndroidFlutterUpdater.setReleaseType(_channel);
                Navigator.of(context).pop();
              }
            },
            child: Text("Apply")),
      ],
    );
  }
}
