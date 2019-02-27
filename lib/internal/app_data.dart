class AppData {
  static final AppData _singleton = new AppData._internal();

  double scaleFactorW = 0;
  double scaleFactorH = 0;
  double scaleFactorA = 0;

  factory AppData() {
    return _singleton;
  }

  AppData._internal();
}
