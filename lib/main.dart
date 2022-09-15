import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/background_service.dart';
import 'package:teragate_v3/services/beacon_service.dart';
import 'package:teragate_v3/services/network_service.dart';
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

    startBeaconTimer(null, secureStorage!).then((timer) => beaconTimer = timer);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groupware WorkOn',
      debugShowCheckedModeBanner: false,
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
      home: MyHomePage(beaconStreamController: beaconStreamController!),
    );
  }
}

// deprecated
class MyHomePage extends StatefulWidget {
  final StreamController beaconStreamController;
  const MyHomePage({required this.beaconStreamController, Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = "";

  late StreamController eventStreamController;
  late StreamController weekStreamController;

  late SecureStorage secureStorage;

  Timer? beaconTimer;

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();

    eventStreamController = StreamController<String>.broadcast();
    Env.EVENT_STREAM_SUBSCRIPTION = eventStreamController.stream.listen((event) {
      // eventStreamSubscription = eventStreamController.stream.listen((event) {
      if (event.isNotEmpty) {
        WorkInfo workInfo = WorkInfo.fromJson(json.decode(event));
        Env.EVENT_FUNCTION == null ? Log.debug(workInfo.success.toString()) : Env.EVENT_FUNCTION!(workInfo);
      }
    });
    SharedStorage.deleteAllIOS().then((value) {
      _checkLogin().then((state) {
        Log.debug("Login State : $state");
        if (state != null && state == "true") {
          _setEnv();
          _initForBeacon();
          initIp().then((value) => Env.CONNECTIVITY_STREAM_SUBSCRIPTION = value);
          sendMessageByWork(context, secureStorage).then((workInfo) {
            Env.INIT_STATE_WORK_INFO = workInfo;

            sendMessageByWeekWork(context, secureStorage).then((weekInfo) {
              Env.INIT_STATE_WEEK_INFO = weekInfo;
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            });
          });
        } else {
          if (Platform.isIOS) {
            _initForBeacon();
            Future.delayed(const Duration(seconds: 5), () {
              stopBeacon();
            });
          }
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
    return const Scaffold(
      body: null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _initForBeacon() async {
    Env.BEACON_STREAM_SUBSCRIPTION = startBeaconSubscription(widget.beaconStreamController, secureStorage);
    initBeacon(context, widget.beaconStreamController, secureStorage, null);
  }

  Future<String?> _checkLogin() async {
    return await secureStorage.read(Env.LOGIN_STATE);
  }

  void _setEnv() async {
    Env.WORK_PHOTO_PATH = (await secureStorage.read(Env.KEY_PHOTO_PATH)) ?? "";
    Env.WORK_KR_NAME = (await secureStorage.read(Env.KEY_KR_NAME)) ?? "";
    Env.WORK_POSITION_NAME = (await secureStorage.read(Env.KEY_POSITION_NAME)) ?? "";
    Env.WORK_COMPANY_NAME = (await secureStorage.read(Env.KEY_COMPANY_NAME)) ?? "";
    Env.BACKGROUND_PATH = await secureStorage.read(Env.KEY_BACKGROUND_PATH) ?? "theme2.png";
    SharedStorage.readList(Env.KEY_SHARE_UUID).then((uuids) {
      uuids = uuids ?? [];
      for (String uuid in uuids) {
        _setUUID(uuid);
      }
    });
  }

  void _setUUID(String uuid) async {
    Env.UUIDS[uuid] = (await secureStorage.read(uuid)) ?? "";
  }
}
