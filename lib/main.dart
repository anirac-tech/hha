import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore:depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:starter_architecture_flutter_firebase/firebase_options.dart';
import 'package:starter_architecture_flutter_firebase/src/app.dart';
import 'package:starter_architecture_flutter_firebase/src/localization/string_hardcoded.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // turn off the # in the URLs on the web
  usePathUrlStrategy();
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors
  registerErrorHandlers();
  // * Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(const {
    "help_button_text": "... help local default",
    "help_screen_html": '''
          <b>Bold works, lists work</b><ol><li>local default</li><li>but can remote</li><li>even via audience</li></ol>
    <img height="200" width="200" alt="train" src="https://images.pexels.com/photos/27583783/pexels-photo-27583783/free-photo-of-a-classic-yellow-tram-in-lisbon.jpeg"/>

        '''
  });
  await remoteConfig.fetchAndActivate();
  if (!kIsWeb) {
    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();

      helpButtonText = remoteConfig.getString("help_button_text");
      helpScreenHtml = remoteConfig.getString("help_screen_html");
    });
  }
  helpButtonText = remoteConfig.getString("help_button_text");
  helpScreenHtml = remoteConfig.getString("help_screen_html");
  // TODO: Make the magic strings constants.
  // * Entry point of the app
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

String helpButtonText = '';
String helpScreenHtml = '';

void registerErrorHandlers() {
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('An error occurred'.hardcoded),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
