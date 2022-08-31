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
      initialRoute: "/login",
      routes: <String, WidgetBuilder>{
        "/login": (BuildContext context) => Login(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/home": (BuildContext context) => Home(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/place": (BuildContext context) => Place(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/theme": (BuildContext context) => ThemeMain(eventStreamController: eventStreamController!, beaconStreamController: beaconStreamController!),
        "/week": (BuildContext context) => Week(eventStreamController: eventStreamController!, weekStreamController: weekStreamController!, beaconStreamController: beaconStreamController!)
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

  Future<void> _broadcastByEvent(String type, dynamic data) async {
    if (type == Env.WORK_TYPE_TODAY) {
      eventStreamController!.add(data);
    } else if (type == Env.WORK_TYPE_WEEK) {
      weekStreamController!.add(data);
    }
  }
}

// deprecated
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = "";

  late StreamController eventStreamController;
  StreamController? beaconStreamController;
  late StreamController weekStreamController;

  late StreamSubscription connectivityStreamSubscription;
  late StreamSubscription beaconStreamSubscription;
  late StreamSubscription eventStreamSubscription;

  late SecureStorage secureStorage;

  Timer? beaconTimer;

  @override
  void initState() {
    secureStorage = SecureStorage();

    callPermissions();

    _createUuidsOfTest();

    initIp().then((value) => connectivityStreamSubscription = value);

    eventStreamController = StreamController<String>.broadcast();
    eventStreamSubscription = eventStreamController.stream.listen((event) {
      if (event.isNotEmpty) {
        WorkInfo workInfo = WorkInfo.fromJson(json.decode(event));
      }
    });

    startBeaconTimer(context, _successCheck, secureStorage).then((timer) => beaconTimer = timer);

    move();
  }

  @override
  void dispose() {
    eventStreamSubscription.cancel();
    eventStreamController.onCancel!();
    stopTimer(beaconTimer);
    super.dispose();
  }

  void _sampleSendMessage() {
    // String id = "raindrop891";
    // String pw = "raindrop891";

    // login
    // login(id, pw).then((loginInfo) {
    //   secureStorage.write(Env.KEY_ACCESS_TOKEN, loginInfo.tokenInfo!.getAccessToken());
    //   secureStorage.write(Env.KEY_REFRESH_TOKEN, loginInfo.tokenInfo!.getRefreshToken());
    //   secureStorage.write(Env.KEY_USER_ID, loginInfo.data!["userId"].toString());

      // Env.WORK_PHOTO_PATH = loginInfo.getPhotoPath();
      // Env.WORK_KR_NAME = loginInfo.getKrName();
      // Env.WORK_POSITION_NAME = loginInfo.getPositionName();
      // Env.WORK_COMPANY_NAME = loginInfo.getCompanyName();

      // Log.debug(" photopath = ${loginInfo.getKrName()}");
      // Log.debug(" krname = ${loginInfo.getPhotoPath()}");
      // Log.debug(" positionname = ${loginInfo.()}");
      // Log.debug(" companyName = ${loginInfo.getCompanyName()}");

    //   // state 페이지 이동
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => MySamplePage(
    //               title: "sample",
    //               eventStreamController: eventStreamController,
    //               beaconStreamController: beaconStreamController,
    //               weekStreamController: weekStreamController,
    //               connectivityStreamSubscription: connectivityStreamSubscription,
    //               beaconStreamSubscription: beaconStreamSubscription,
    //               eventStreamSubscription: eventStreamSubscription)));

    //   // 이슈 정보 등록
    //   // sendMessageTracking(context, secureStorage, Env.UUID_DEFAULT, "인비전테크놀로지 사무실").then((workInfo) {
    //   //   Log.debug(" success === ${workInfo.success.toString()} ");
    //   // });

    //   // 금일 출근 퇴근 정보 요청
    //   // sendMessageByWork(context, secureStorage).then((workInfo) {
    //   //   Log.debug(" success === ${workInfo.success.toString()} ");
    //   // });

    //   // 일주일간 출근 퇴근 정보 요청
    //   // sendMessageByWeekWork(context, secureStorage).then((weekInfo) {
    //   //   Log.debug(" success === ${workInfo.success.toString()} ");
    //   // });

    //   // 비콘 정보 요청 ( 동기화 )
    //   // sendMessageByBeacon(context, secureStorage).then((configInfo) {
    //   //   Log.debug(" success === ${configInfo.success.toString()} ");
    //   // });
    // });
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          MoveToBackground.moveTaskToBack();
          return Future(() => false);
        },
        child: widget);
  }

  @override
  Widget build(BuildContext context) {
    return _createWillPopScope(Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$result ',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.focused)) return Colors.red;
                  return null; // Defer to the widget's default.
                }),
              ),
              child: Text(
                'Beacon',
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                _initForBeacon();
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sampleSendMessage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ));
  }

  Future<void> _initForBeacon() async {
    if (beaconStreamController == null) {
      beaconStreamController = StreamController<String>.broadcast();
      initBeacon(context, beaconStreamController!, secureStorage);
    }
  }

  Future<void> _startForBeacon() async {
    beaconStreamSubscription = startBeaconSubscription(beaconStreamController!, secureStorage, null);
  }

  void _createUuidsOfTest() {
    String sampleUUID1 = "12345678-9A12-3456-789B-123456FFFFFF";
    String sampleUUID2 = "74278BDB-B644-4520-8F0C-720EEAFFFFFF";

    String samplePlace1 = "사무실";
    String samplePlace2 = "회의실";

    Env.UUIDS[sampleUUID1] = samplePlace1;
    Env.UUIDS[sampleUUID2] = samplePlace2;
  }

  void _successCheck(WorkInfo workInfo) {
    Log.debug(" ${workInfo.message} ");
  }

  Future<void> move() async {
    String? id = await secureStorage.read(Env.LOGIN_ID);
    String? pw = await secureStorage.read(Env.LOGIN_PW);

    if (id == null || pw == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(eventStreamController: eventStreamController, beaconStreamController: beaconStreamController!)));
    }

    login(id!, pw!).then((loginInfo) {
      secureStorage.write(Env.KEY_ACCESS_TOKEN, loginInfo.tokenInfo!.getAccessToken());
      secureStorage.write(Env.KEY_REFRESH_TOKEN, loginInfo.tokenInfo!.getRefreshToken());
      secureStorage.write(Env.KEY_USER_ID, loginInfo.data!["userId"].toString());

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(eventStreamController: eventStreamController, beaconStreamController: beaconStreamController!)));
    });
  }
}
