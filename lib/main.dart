import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:fluro/fluro.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/data_layer/repository/middleware.dart';
import 'package:moxie_fitness/data_layer/reducers/reducers.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:moxie_fitness/providers/notifications_provider.dart';
import 'package:moxie_fitness/providers/root_providers.dart';
import 'package:provider/provider.dart';
import 'package:redux/redux.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
  // change the default route of the app
  // var notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  runApp(providers);
}

class MoxieApp extends StatelessWidget {
  final store = Store<MoxieAppState>(
    appReducer,
    initialState: MoxieAppState.loading(),
    middleware: createStoreMiddleware(moxieRepository),
  );
  @override
  Widget build(BuildContext context) {
    return StoreProvider<MoxieAppState>(store: store, child: MoxieAppTree());
  }
}

class MoxieAppTree extends StatefulWidget {
  @override
  State createState() {
    return _MoxieAppTreeState();
  }
}

class _MoxieAppTreeState extends State<MoxieAppTree> {
  _MoxieAppTreeState() {
    final router = Router();
    Routes.configureDefaultRoutes(router);
    Routes.router = router;
  }

  final platform = MethodChannel('crossingthestreams.io/resourceResolver');

  @override
  initState() {
    super.initState();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) =>
                NotificationsProvider.onDidReceiveLocalNotification(
                    context, id, title, body, payload));
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) =>
            NotificationsProvider.onSelectNotification(context, payload));
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
        title: 'Moxie Fitness',
        theme: ThemeData(
            primarySwatch: Colors.deepOrange,
            errorColor: Colors.white,
            accentColor: Colors.blue),
        onGenerateRoute: Routes.router.generator,
        debugShowCheckedModeBanner: false);
    print("initial route = ${app.initialRoute}");
    return app;
  }
}
