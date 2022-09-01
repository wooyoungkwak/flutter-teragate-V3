import 'dart:async';
import 'dart:convert';
import 'package:teragate_v3/config/env.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/background_service.dart';
import 'package:flutter/material.dart';
import 'package:teragate_v3/state/widgets/bottom_navbar.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/utils/log_util.dart';

import 'package:teragate_v3/services/server_service.dart';

class Home extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const Home({required this.eventStreamController, required this.beaconStreamController, Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late StreamSubscription beaconStreamSubscription;
  late StreamSubscription eventStreamSubscription;

  late BeaconInfoData beaconInfoData;

  late SecureStorage secureStorage;

  String currentHour = "";
  String currentMinute = "";
  String currentDay = "";
  String company = "";
  String profilePicture = "";
  String profileName = "";
  String profilePosition = "";
  String currentTimeHHMM = "";
  String workState = "";
  String workTime = "";
  String getInTime = "";
  String getOutTime = "";
  String currentLocation = "";

  @override
  void initState() {
    super.initState();
    setUI(location: "외부");

    secureStorage = SecureStorage();

    eventStreamSubscription = widget.eventStreamController.stream.listen((event) {
      if (event.isNotEmpty) {
        WorkInfo workInfo = WorkInfo.fromJson(json.decode(event));
        Log.debug("workInfo === ${workInfo.toString()}");
      }
    });
    beaconStreamSubscription = startBeaconSubscription(widget.beaconStreamController, secureStorage, setBeaconUI);
  }

  @override
  void dispose() {
    beaconStreamSubscription.cancel();
    eventStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () {
        // Navigator.pop(context);
        MoveToBackground.moveTaskToBack();
        return Future(() => false);
      },
      child: Container(
        // 배경화면
        padding: EdgeInsets.only(top: statusBarHeight),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          // 메인화면
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // 로그아웃 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    margin: const EdgeInsets.only(top: 20.0, right: 20.0),
                    // padding: const EdgeInsets.all(1.0),
                    decoration: const BoxDecoration(),
                    child: Material(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          showAlertDialog(context);
                          // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6.0),
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 18.0,
                          color: Color(0xff3450FF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 메인화면
              Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시.분 / 월.일.요일
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: currentHour,
                            size: 80,
                            color: Colors.black,
                          ),
                          // Divider
                          Container(
                            height: 2,
                            width: 95,
                            color: const Color.fromARGB(255, 25, 25, 25),
                          ),
                          CustomText(
                            text: currentMinute,
                            size: 80,
                          ),
                          CustomText(
                            text: currentDay,
                            weight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                    // 빈공간
                    Expanded(
                      flex: 5,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    // 회사명
                    CustomText(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      text: company,
                      weight: FontWeight.w500,
                    ),
                    // 프로필
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              profilePicture,
                              fit: BoxFit.cover,
                              width: 48,
                              height: 48,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomText(
                                padding: const EdgeInsets.only(left: 14.0, right: 4.0),
                                text: profileName,
                                size: 28.0,
                              ),
                              CustomText(
                                padding: const EdgeInsets.only(bottom: 2.0),
                                text: profilePosition,
                                weight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 근태 상태
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _createWorkCard(
                              color: _setWorkStateColor(workState),
                              title: workState,
                              time: workTime,
                              currentTime: currentTimeHHMM,
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: _createWorkCard(
                                color: _setGetInColor(getInTime),
                                title: "출근",
                                time: getInTime,
                              )),
                          Expanded(
                              flex: 2,
                              child: _createWorkCard(
                                color: _setGetOutColor(getOutTime),
                                title: "퇴근",
                                time: getOutTime,
                              )),
                        ],
                      ),
                    ),
                    // 빈공간
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bottom Navigation Bar
          bottomNavigationBar: BottomNavBar(
            currentLocation: currentLocation,
            currentTime: currentTimeHHMM,
          ),
        ),
      ),
    );
  }

  // WillPopScope _createWillPopScope(Widget widget) {
  //   return WillPopScope(
  //       onWillPop: () {
  //         MoveToBackground.moveTaskToBack();
  //         return Future(() => false);
  //       },
  //       child: widget);
  // }

  Card _createWorkCard({
    Color color = Colors.white,
    String? title,
    String? time,
    String? currentTime,
  }) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              padding: const EdgeInsets.all(5.0),
              text: title!,
              size: 14.0,
              weight: FontWeight.w400,
              color: color == Colors.white ? Colors.black : Colors.white,
            ),
            CustomText(
              padding: const EdgeInsets.all(5.0),
              text: time!,
              color: color == Colors.white ? Colors.black : Colors.white,
            ),
            if (currentTime != null)
              CustomText(
                padding: const EdgeInsets.all(5.0),
                text: "현재시간 : $currentTime",
                size: 13.0,
                weight: FontWeight.w400,
              ),
          ],
        ),
      ),
    );
  }

  void setUI({required String location}) {
    setState(() {
      currentHour = "01";
      currentMinute = "52";
      currentDay = "6월 21일 화요일";
      company = "주식회사 테라비전";
      profilePicture = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7X1a5uXND5eV1xt1ihm1RqafYqZ2_iFAWeg&usqp=CAU';
      profileName = "홍길동";
      profilePosition = "과장";
      currentTimeHHMM = "19:55";
      workState = "업무중";
      workTime = "08:30~18:00";
      getInTime = "08:12";
      getOutTime = "18:00";
      currentLocation = location;
    });
  }

  Color _setWorkStateColor(String workState) {
    if (workState == "업무외") {
      return const Color(0xff7C8298);
    } else if (workState == "업무중") {
      return const Color(0xff25A45F);
    } else {
      return Colors.white;
    }
  }

  Color _setGetInColor(String getInTime) {
    if (getInTime == "08:12") {
      return const Color(0xff3C5FEB);
    } else {
      return Colors.white;
    }
  }

  Color _setGetOutColor(String getOutTime) {
    if (getOutTime == "18:00") {
      return const Color(0xffFF3823);
    } else {
      return Colors.white;
    }
  }

  void setBeaconUI(BeaconInfoData beaconInfoData) {
    this.beaconInfoData = beaconInfoData;
  }

  void showAlertDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('알림'),
        content: const Text('로그인 페이지로 이동하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => {
              Navigator.pop(context, 'OK'),
              _logout(context),
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    secureStorage.read(Env.KEY_ID_CHECK).then((value) {
      if (value == null && value == "false") {
        secureStorage.write(Env.LOGIN_ID, "");
      }
    });
    secureStorage.write(Env.LOGIN_PW, "");
    secureStorage.write(Env.LOGIN_STATE, "false");
    secureStorage.write(Env.KEY_ACCESS_TOKEN, "");
    secureStorage.write(Env.KEY_REFRESH_TOKEN, "");
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
