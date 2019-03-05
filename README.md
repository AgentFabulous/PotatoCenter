# PotatoCenter

A brand new OTA app written in Flutter for updating Android. Written with [
POSP](https://potatoproject.co/) in mind, it works with the [android_flutter_updater](https://github.com/AgentFabulous/android_flutter_updater) plugin to interact with native components of Android such as [UpdateEngine](https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/os/UpdateEngine.java) to serve a hassle free update experience.

## Setting up
- Open the project in Android Studio.
- Add your project's framework.jar to android/libs
- Run flutter packages get 
- Run main.dart

## Contributing
- This app is mostly a minimal frontend for the [plugin](https://github.com/AgentFabulous/android_flutter_updater).
- When submitting changes, be sure to [reformat your sources](https://flutter.dev/docs/development/tools/formatting) in Android Studio.
