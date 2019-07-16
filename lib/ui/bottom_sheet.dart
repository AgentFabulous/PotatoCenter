import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/provider/app_info.dart';
import 'package:potato_center/provider/download.dart';
import 'package:potato_center/provider/sheet_data.dart';
import 'package:provider/provider.dart';

BorderRadius _kBorderRadius = BorderRadius.circular(12);

class BottomSheetContents extends StatelessWidget {
  final int currentValue = 0;
  final List<String> intervals = [
    'Never',
    'Once a day',
    'Once a week',
    'Once a month'
  ];

  final List<int> intervalIndex = [0, 1, 2, 3];
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final appInfo = Provider.of<AppInfoProvider>(context);
    final sheetData = Provider.of<SheetDataProvider>(context);
    final foregroundColor = HSLColor.fromColor(Theme.of(context).accentColor)
        .withLightness(0.85)
        .toColor();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        sheetData.isHandleVisible = false;
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        sheetData.isHandleVisible = true;
      }
    });

    return Theme(
      data: Theme.of(context).copyWith(
        toggleableActiveColor: Theme.of(context).brightness == Brightness.dark
            ? foregroundColor
            : Theme.of(context).accentColor,
      ),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 40),
            child: Column(children: <Widget>[
              ListTile(
                title: Text('Update check interval'),
                trailing: DropdownButton(
                  value: sheetData.checkInterval,
                  items: intervalIndex
                      .map((int val) => DropdownMenuItem(
                            value: val,
                            child: Text(intervals[val]),
                          ))
                      .toList(),
                  onChanged: (v) => sheetData.checkInterval = v,
                ),
              ),
              ListTile(
                title: Text('Mobile data warning'),
                trailing: Switch(
                  value: sheetData.dataWarn,
                  onChanged: (v) => sheetData.dataWarn = v,
                ),
              ),
              ListTile(
                  title: Text('Delete updates when installed'),
                  trailing: Switch(
                    value: sheetData.autoDelete,
                    onChanged: (v) => sheetData.autoDelete = v,
                  )),
              sheetData.isABDevice
                  ? ListTile(
                      title: Text('Install updates faster'),
                      trailing: Switch(
                          value: sheetData.perfMode,
                          onChanged: (v) => sheetData.perfMode = v),
                    )
                  : Container(),
              Divider(),
              ifUpdateWidget(
                ListTile(
                  onTap: () => launchUrl('https://potatoproject.co/changelog'),
                  title: Text('Changelog'),
                  trailing: Icon(Icons.code),
                ),
                flipCondition: true,
              ),
              ListTile(
                onTap: () => launchUrl('https://potatoproject.co'),
                title: Text('Website'),
                trailing: Icon(Icons.public),
              ),
              ListTile(
                onTap: () => launchUrl('https://twitter.com/PotatoAndroid'),
                title: Text('Twitter'),
                trailing: Icon(MdiIcons.twitter),
              ),
              ListTile(
                onTap: () => launchUrl('https://t.me/SaucyPotatoesOfficial'),
                title: Text('Telegram'),
                trailing: Icon(MdiIcons.telegram),
              )
            ]),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (_scrollController.offset != 0) {
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  sheetData.isHandleVisible = true;
                } else {
                  if (!appInfo.isDeveloper) {
                    appInfo.devCounter++;
                    if (appInfo.isDeveloper) Navigator.of(context).pop();
                  }
                }
              },
              onLongPress: () {
                appInfo.isDeveloper = false;
                Navigator.of(context).pop();
              },
              child: AnimatedOpacity(
                opacity: sheetData.isHandleVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Container(
                        height: 5,
                        width: 75,
                        decoration: BoxDecoration(
                          color: foregroundColor,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperBottomSheetContents extends StatefulWidget {
  @override
  _DeveloperBottomSheetContentsState createState() =>
      _DeveloperBottomSheetContentsState();
}

class _DeveloperBottomSheetContentsState
    extends State<DeveloperBottomSheetContents> {
  final key = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final sheetData = Provider.of<SheetDataProvider>(context);
      _scrollController.addListener(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          sheetData.isHandleVisible = false;
        }
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          sheetData.isHandleVisible = true;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appInfo = Provider.of<AppInfoProvider>(context);
    final sheetData = Provider.of<SheetDataProvider>(context);
    final backgroundColor = HSLColor.fromColor(Theme.of(context).accentColor)
        .withLightness(0.85)
        .toColor();
    final foregroundColor = HSLColor.fromColor(Theme.of(context).accentColor)
        .withLightness(0.4)
        .toColor();
    return Theme(
      data: Theme.of(context).copyWith(
        toggleableActiveColor: Theme.of(context).brightness == Brightness.dark
            ? backgroundColor
            : Theme.of(context).accentColor,
      ),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(children: <Widget>[
                  FutureBuilder(
                    key: key,
                    initialData: '',
                    future: AndroidFlutterUpdater.getReleaseType(),
                    builder: (context, snapshot) => ListTile(
                      title: Text('Update channel'),
                      subtitle: Text('Current: ${snapshot.data}'),
                      trailing: RaisedButton(
                        color: backgroundColor,
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => ChannelSelector(),
                        ),
                        child: Text(
                          'Change',
                          style: TextStyle(color: foregroundColor),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Build verification'),
                    trailing: FutureBuilder(
                      initialData: true,
                      future: AndroidFlutterUpdater.getVerify(),
                      builder: (context, snapshot) => Switch(
                        value: snapshot.data,
                        onChanged: (b) => AndroidFlutterUpdater.setVerify(b)
                            .then((v) => setState(() {})),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (_scrollController.offset != 0) {
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  sheetData.isHandleVisible = true;
                } else {
                  if (!appInfo.isDeveloper) {
                    appInfo.devCounter++;
                    if (appInfo.isDeveloper) Navigator.of(context).pop();
                  }
                }
              },
              onLongPress: () {
                appInfo.isDeveloper = false;
                Navigator.of(context).pop();
              },
              child: AnimatedOpacity(
                opacity: sheetData.isHandleVisible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Center(
                      child: Container(
                        height: 5,
                        width: 75,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelSelector extends StatefulWidget {
  @override
  _ChannelSelectorState createState() => _ChannelSelectorState();
}

class _ChannelSelectorState extends State<ChannelSelector> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final foregroundColor = HSLColor.fromColor(Theme.of(context).accentColor)
        .withLightness(0.4)
        .toColor();
    TextStyle _buttonTextStyle = TextStyle(color: foregroundColor);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: _kBorderRadius,
      ),
      title: Text('Update channel'),
      content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Channel name'),
            validator: (value) {
              if (value.isEmpty)
                return 'Please enter a channel name';
              else
                return null;
            },
          ),
        )
      ]),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: _buttonTextStyle),
        ),
        FlatButton(
          onPressed: () async {
            await AndroidFlutterUpdater.setReleaseType('__default__');
            Navigator.of(context).pop();
            await Provider.of<DownloadProvider>(context).loadData();
          },
          child: Text('Reset', style: _buttonTextStyle),
        ),
        FlatButton(
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              await AndroidFlutterUpdater.setReleaseType(_controller.text);
              Navigator.of(context).pop();
              await Provider.of<DownloadProvider>(context).loadData();
            }
          },
          child: Text('Apply', style: _buttonTextStyle),
        ),
      ],
    );
  }
}
