import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/background_service.dart';
import 'package:teragate_v3/services/beacon_service.dart';
import 'package:teragate_v3/services/network_service.dart';
import 'package:teragate_v3/services/permission_service.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/state/home_state.dart';
import 'package:teragate_v3/state/login_state.dart';
import 'package:teragate_v3/state/place_state.dart';
import 'package:teragate_v3/state/theme_state.dart';
import 'package:teragate_v3/state/week_state.dart';
import 'package:teragate_v3/utils/log_util.dart';

void main() {
  MyApp myApp = MyApp();
  myApp.init();
  runApp(myApp);
}

class MyApp extends StatelessWidget {
  StreamController? eventStreamController;
  StreamController? beaconStreamController;
  StreamController? weekStreamController;

  SecureStorage? secureStorage;
  Timer? beaconTimer;

  MyApp({this.eventStreamController, this.beaconStreamController, this.weekStreamController, Key? key}) : super(key: key);

  void init() {
    beaconStreamController = StreamController<String>.broadcast();
    eventStreamController = StreamController<String>.broadcast();
    weekStreamController = StreamController<String>.broadcast();
    secureStorage = SecureStorage();

    startBeaconTimer(null, _broadcastByEvent, secureStorage!).then((timer) => beaconTimer = timer);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groupware WorkOn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute: "/login",
      routes: <String, WidgetBuilder>{
        "/login": (BuildContext context) => Login(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/home": (BuildContext context) => Home(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/place": (BuildContext context) => Place(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/theme": (BuildContext context) => ThemeMain(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/week": (BuildContext context) => Week(eventStreamController: eventStreamController!, weekStreamController: weekStreamController!, beaconStreamController: beaconStreamController!)
      },
      home: const MyHomePage(),
    );
  }

  Future<void> _broadcastByEvent(String type, dynamic data) async {
    if (type == Env.WORK_TYPE_TODAY) {
      eventStreamController!.add(data.toString());
    } else if (type == Env.WORK_TYPE_WEEK) {
      weekStreamController!.add(data.toString());
    }
  }
}

// deprecated
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = "";

  late StreamController eventStreamController;
  StreamController? beaconStreamController;
  late StreamController weekStreamController;

  late StreamSubscription beaconStreamSubscription;
  late StreamSubscription eventStreamSubscription;

  late SecureStorage secureStorage;

  Timer? beaconTimer;

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();

    eventStreamController = StreamController<String>.broadcast();
    eventStreamSubscription = eventStreamController.stream.listen((event) {
      if (event.isNotEmpty) {
        WorkInfo workInfo = WorkInfo.fromJson(json.decode(event));
      }
    });

    _checkLogin().then((state) {
      Log.debug("Login State : ${state}");
      if (state != null && state == "true") {
        _initForBeacon();
        initIp().then((value) => Env.CONNECTIVITY_STREAM_SUBSCRIPTION = value);
        sendMessageByWork(context, secureStorage).then((workInfo) {
          _setEnv();
          Env.INIT_STATE_INFO = workInfo;
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        });
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    eventStreamSubscription.cancel();
    // eventStreamController.onCancel!();
    // stopTimer(beaconTimer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _initForBeacon() async {
    if (beaconStreamController == null) {
      beaconStreamController = StreamController<String>.broadcast();
      initBeacon(context, beaconStreamController!, secureStorage);
    }
  }

  Future<String?> _checkLogin() async {
    return await secureStorage.read(Env.LOGIN_STATE);
  }

  void _setEnv() async {
    Env.WORK_PHOTO_PATH = (await secureStorage.read(Env.KEY_PHOTO_PATH)) ?? "";
    Env.WORK_KR_NAME = (await secureStorage.read(Env.KEY_KR_NAME)) ?? "";
    Env.WORK_POSITION_NAME = (await secureStorage.read(Env.KEY_POSITION_NAME)) ?? "";
    Env.WORK_COMPANY_NAME = (await secureStorage.read(Env.KEY_COMPANY_NAME)) ?? "";

    SharedStorage.readList(Env.KEY_SHARE_UUID).then((uuids) {
      for (String uuid in uuids!) {
        _setUUID(uuid);
      }
    });
  }

  void _setUUID(String uuid) async {
    Env.UUIDS[uuid] = (await secureStorage.read(uuid)) ?? "";
  }
}
