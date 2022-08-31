import 'dart:async';
import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/background_service.dart';
import 'package:flutter/material.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/state/place_state.dart';
import 'package:teragate_v3/state/widgets/bottom_navbar.dart';
import 'package:teragate_v3/state/widgets/coustom_businesscard.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:get/get.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

class Week extends StatefulWidget {
  final StreamController weekStreamController;
  final StreamController beaconStreamController;
  final StreamController eventStreamController;

  const Week(
      {required this.weekStreamController,
      required this.beaconStreamController,
      required this.eventStreamController,
      Key? key})
      : super(key: key);
  State<Week> createState() => _WeekState();
}

class _WeekState extends State<Week> {
  late StreamSubscription beaconStreamSubscription;
  late StreamSubscription weekStreamSubscription;

  late BeaconInfoData beaconInfoData;

  late SecureStorage secureStorage;

  int worktime = 32;
  List<String> week = [];
  List<String> workinTime = [];
  List<String> workoutTime = [];
  List<String> weekinTime = [];
  List<String> weekoutTime = [];
  List<bool> workinOk = []; // 정상 출근 true/ 지각 false
  List<bool> workoutOk = []; // 정상 출근 true/ 조기퇴근 false
  List<bool> today = []; // 오늘날짜 색 변경 변수 이름이 떠오르지않음...

  String currentTimeHHMM = "";
  String currentLocation = "";

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();

    weekStreamSubscription = widget.weekStreamController.stream.listen((event) {
      if (event.isNotEmpty) {
        WorkInfo workInfo = WorkInfo.fromJson(json.decode(event));
      }
    });

    beaconStreamSubscription = startBeaconSubscription(
        widget.beaconStreamController, secureStorage, setBeaconUI);

    setUI();
    //Get.to(Home);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    // final controller = Get.put(Controller());
    // controller.increment();

    return _createWillPopScope(Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: const BoxDecoration(color: Color(0xffF5F5F5)),
      child: Scaffold(
          body: Stack(
            children: [
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
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
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
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                padding: const EdgeInsets.only(top: 15),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      CustomText(
                                        text: "금주 출퇴근 시간",
                                        size: 18,
                                        weight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ])),
                          ],
                        )),
                    Expanded(
                        flex: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: 10, child: initListView()),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CustomText(
                                    text: "이번 주 설정된총 근무 시간은",
                                    size: 12,
                                    weight: FontWeight.normal,
                                    color: Color(0xff6E6C6C),
                                  ),
                                  CustomText(
                                    text: "*$worktime",
                                    size: 12,
                                    weight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  const CustomText(
                                    text: "시간 입니다",
                                    size: 12,
                                    weight: FontWeight.normal,
                                    color: Color(0xff6E6C6C),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                    Expanded(
                        flex: 2,
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            child: _createContainerwhite(
                                const CustomBusinessCard(
                                    company: "주식회사 테라비전",
                                    name: "홍길동",
                                    position: "과장",
                                    worktime: "09:00 ~ 18:00",
                                    workbool: true)))),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentLocation: currentLocation,
            currentTime: currentTimeHHMM,
            // currentLocation: beaconInfoData.place,
            // currentTime: getPickerTime(getNow()),
          )),
    ));
  }

  @override
  void dispose() {
    beaconStreamSubscription.cancel();
    weekStreamSubscription.cancel();
    super.dispose();
  }

  Container _createContainer(Widget widget) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xff3C5FEB),
            borderRadius: BorderRadius.circular(6)),
        child: widget);
  }

  Container _createContainerwhite(Widget widget) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: widget);
  }

  ListView initListView() {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 10),
        itemCount: week.length,
        itemBuilder: (BuildContext context, int index) {
          return Expanded(
            child: initContainerByWork(index),
          );
        });
  }

  // 아이콘 ,요일, 출퇴근 시간 text
  Container initContainerByweektext(Color color, String week, String workintime,
      String workouttime, bool today) {
    if (today == true) {
      color = Color(0xff25A45F);
    }
    return Container(
        margin: const EdgeInsets.only(left: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //나중에 상태에 따른 아이콘 색 변경 추가
            CustomText(text: "·", size: 40, color: color),
            // Icon(Icons.keyboard_double_arrow_right_rounded),
            const SizedBox(width: 5),
            Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(6)),
                child: CustomText(text: week, size: 13)),
            const SizedBox(width: 10),
            CustomText(text: workintime, size: 13, color: Colors.black),
            CustomText(text: "~", size: 13, color: Colors.black),
            CustomText(text: workouttime, size: 13, color: Colors.black)
          ],
        ));
  }

  Container initOpacityByworktime(
      String workTime, bool workOk, bool workinoutCheck) {
    Color workColor;
    //workOk 정상적인 출 퇴근 true : false 지각,조기퇴근 등
    //workinoutCheck 들어온 값이 출근인지 퇴근인지 [true:출근 false:퇴근 색이 다름]
    if (workinoutCheck) {
      workColor = const Color(0xff25A45F);
    } else {
      workColor = const Color(0xffFF3823);
    }

    if (workOk == true) {
      workColor = const Color(0xff7C8298);
    }

    Color workissueColor = Colors.pink; //이슈의 색(지각,조기퇴근 등)
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: workColor, borderRadius: BorderRadius.circular(6)),
      child: Text(workTime),
    );
  }

  Container initContainerByWork(int i) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          initContainerByweektext(
              weekoutTime[i] != "" && weekinTime[i] != ""
                  ? Color(0xff3C5FEB)
                  : Color(0xff77787B),
              week[i],
              weekinTime[i],
              weekoutTime[i],
              today[i]),
          SizedBox(
            child: Row(
              children: [
                weekinTime[i] != ""
                    ? initOpacityByworktime(weekinTime[i], workinOk[i], true)
                    : Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: false,
                        child: initOpacityByworktime(
                            weekinTime[i], workinOk[i], true)),
                weekoutTime[i] != ""
                    ? initOpacityByworktime(weekoutTime[i], workoutOk[i], false)
                    : Visibility(
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        visible: false,
                        child: initOpacityByworktime(
                            weekinTime[i], workinOk[i], true)),
              ],
            ),
          ),
        ]));
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future(() => false);
        },
        child: widget);
  }

  void setUI() {
    int count = 0;
    sendMessageByWeekWork(context, secureStorage).then((weekInfo) {
      // Log.debug(" success === ${workInfo.success.toString()} ");
      Log.debug(weekInfo.success);
      Log.debug(weekInfo.workInfos);
      List<WorkInfo> worklist = weekInfo.workInfos;
      for (int i = 0; i <= worklist.length; i++) {
        worklist[i].isweekend;
        worklist[i].isholiday;
        workinTime[i] = worklist[i].targetAttendTime!;
        workoutTime[i] = worklist[i].targetLeaveTime!;
        worklist[i].attendtime;
        worklist[i].leavetime;
        if (worklist[i].isweekend == "true" ||
            worklist[i].isholiday == "true") {
          count++;
        }
        if (worklist[i].isweekend == "true") {
          workinTime[i] = "주말";
        } else if (worklist[i].isholiday == "true") {
          workinTime[i] = "휴일";
        }
      }
      Log.debug(worklist[0]);
      // String? isweekend; // 주말 여부
      // String? isholiday; // 휴일 여부
      // String? targetAttendTime; // 출근 해야 되는 시간 (예> 09:00)
      // String? targetLeaveTime; // 퇴근 해야 되는 시간 (예> 18:00)
      // String? attendtime; // 출근 시간
      // String? leavetime; // 퇴근 시간
    });

    setState(() {
      currentTimeHHMM = "asda";
      currentLocation = "dsas";
      // currentTimeHHMM = beaconInfoData.uuid;
      // currentLocation = beaconInfoData.place;
      week = ["월", "화", "수", "목", "금", "토", "일"];

      worktime = (7 - count) * 8;
      //반차에 대한 시간 계산은 나중에...처리

      weekinTime = ["08:30", "08:30", "", "08:30", "08:30", "", ""];
      weekoutTime = [
        "",
        "",
        "18:00",
        "18:00",
        "18:00",
        "",
        "",
      ];
      workinOk = [
        true,
        true,
        false,
        true,
        false,
        true,
        false
      ]; // 정상 출근 true/ 지각 false
      workoutOk = [
        false,
        true,
        true,
        true,
        false,
        true,
        false
      ]; // 정상 출근 true/ 조기퇴근 false
      today = [
        false,
        false,
        false,
        false,
        false,
        true,
        true
      ]; // 오늘날짜 색 변경 변수 이름이 떠오르지않음...
    });
  }

  //일주일간 출근 퇴근 정보 요청

  void setBeaconUI(BeaconInfoData beaconInfoData) {
    this.beaconInfoData = beaconInfoData;
  }

  void sendToBroadcast(WorkInfo workInfo) {
    widget.eventStreamController.add(workInfo.toString());
  }
}
