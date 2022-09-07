import 'dart:async';
import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:teragate_v3/config/env.dart';
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
import 'package:teragate_v3/state/widgets/synchonization_dialog.dart';
import 'package:teragate_v3/utils/alarm_util.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

class Week extends StatefulWidget {
  final StreamController weekStreamController;
  final StreamController beaconStreamController;
  final StreamController eventStreamController;

  const Week({required this.weekStreamController, required this.beaconStreamController, required this.eventStreamController, Key? key}) : super(key: key);

  @override
  State<Week> createState() => _WeekState();
}

class _WeekState extends State<Week> {
  late SimpleFontelicoProgressDialog dialog;
  late SecureStorage secureStorage;
  BeaconInfoData beaconInfoData = BeaconInfoData(uuid: "", place: "");
  int workingtime = 32;
  List<String> week = ["일", "월", "화", "수", "목", "금", "토"];
  List<WorkInfo> worklist = [];
  List<String> workTime = [];
  List<String> weekinTime = [];
  List<String> weekoutTime = [];
  List<bool> workinOk = [true, true, true, true, true, true, true]; // 정상 출근 true/ 지각 false
  List<bool> workoutOk = [true, true, true, true, true, true, true]; // 정상 출근 true/ 조기퇴근 false
  List<bool> today = [false, false, false, false, false, false, false]; // 출근만 찍힌 요일 true/ 출퇴근 모두 찍힌 요일 false .

  WorkInfo? workInfo;

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();

    workInfo = Env.INIT_STATE_WORK_INFO;
    Env.EVENT_FUNCTION = _setUI;
    Env.EVENT_WEEK_FUNCTION = _synchonizationWeekUI;
    Env.BEACON_FUNCTION = _setBeaconUI;

    _initWeekUI();
  }

  @override
  Widget build(BuildContext context) {
    dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable: false, duration: const Duration(milliseconds: 3000));
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
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 40),
                                padding: const EdgeInsets.only(top: 15),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
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
                                    text: "*$workingtime",
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
                            child: createContainerwhite(CustomBusinessCard(Env.WORK_COMPANY_NAME, Env.WORK_KR_NAME, Env.WORK_POSITION_NAME, Env.WORK_PHOTO_PATH, workInfo)))),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentLocation: Env.CURRENT_PLACE,
            currentTime: getPickerTime(getNow()),
            function: _synchonizationWeekUI,
          )),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Container createContainerwhite(Widget widget) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: widget);
  }

  ListView initListView() {
    return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 10),
        itemCount: week.length,
        itemBuilder: (BuildContext context, int index) {
          return initContainerByWork(index);
        });
  }

  // 아이콘 ,요일, 출퇴근 시간 text
  Container initContainerByweektext(Color color, String week, String workTime, bool today) {
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
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                child: CustomText(text: week, size: 13)),
            const SizedBox(width: 10),
            CustomText(text: workTime, size: 13, color: Colors.black),
          ],
        ));
  }

  Container initOpacityByworktime(String workTime, bool workOk, bool workinoutCheck) {
    Color workColor;
    //workOk 정상적인 출 퇴근 true : false 지각,조기퇴근 등
    //workinoutCheck 들어온 값이 출근인지 퇴근인지 [true:출근 false:퇴근 색이 다름]
    if (workinoutCheck) {
      workColor = const Color(0xff25A45F);
    } else {
      workColor = const Color(0xffFF3823);
    }

    // 이슈에 관한 색
    // if (workOk == false) {
    //   workColor = const Color(0xff7C8298);
    // }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: workColor, borderRadius: BorderRadius.circular(6)),
      child: Text(workTime),
    );
  }

  Container initContainerByWork(int i) {
    return Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          initContainerByweektext(weekinTime[i] == "" ? Color(0xff77787B) : Color(0xff3C5FEB), week[i], workTime[i], today[i]),
          //initContainerByweektext(Color(0xff3C5FEB), week[i], workTime[i], today[i]),
          SizedBox(
            child: Row(
              children: [
                weekinTime[i] != ""
                    ? initOpacityByworktime(weekinTime[i], workinOk[i], true)
                    : Visibility(maintainSize: true, maintainAnimation: true, maintainState: true, visible: false, child: initOpacityByworktime(weekinTime[i], workinOk[i], true)),
                weekoutTime[i] != ""
                    ? initOpacityByworktime(weekoutTime[i], workoutOk[i], false)
                    : Visibility(maintainSize: true, maintainAnimation: true, maintainState: true, visible: false, child: initOpacityByworktime(weekinTime[i], workinOk[i], true)),
              ],
            ),
          ),
        ]));
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          MoveToBackground.moveTaskToBack();
          return Future(() => false);
        },
        child: widget);
  }

  Future<void> _synchonizationWeekUI(WeekInfo? weekInfo) async {
    Log.log("동기화 상태 옵니다");
    dialog.show(message: "로딩중...");
    int count = 0;
    workTime.clear;
    if (weekInfo == null) {
      sendMessageByWeekWork(context, secureStorage).then((weekInfo) {
        worklist = weekInfo!.workInfos;
      });
    } else {
      // _showSyncDialog(context, location: Env.CURRENT_PLACE);
      setState(() {
        for (int i = 0; i < worklist.length; i++) {
          Map<String, dynamic> Workstate = getWorkState(worklist[i]);
          Log.debug(worklist[i].toString());

          workTime.add((worklist[i].strAttendLeaveTime!));

          weekinTime.add(worklist[i].attendtime ?? "");
          weekoutTime.add(worklist[i].leavetime ?? "");
          worklist[i].leavetime;
          if (worklist[i].isweekend == "Y" || worklist[i].isholiday == "Y") {
            count++;
          }
          if (Workstate["isAttendTimeOut"]) {
            workinOk[i] = false;
          }
        }
        workingtime = (7 - count) * 8;

        for (int i = 0; i < week.length; i++) {
          if (weekinTime[i] == "" && weekoutTime[i] == "") {
            today[i] = false;
          } else if (weekinTime[i] != "" && weekoutTime[i] == "") {
            today[i] = true;
          } else {
            today[i] = false;
          }
        }
      });
    }
    await Future.delayed(Duration(seconds: 1));
    dialog.hide();
  }

  void _initWeekUI() async {
    int count = 0;
    WeekInfo list = Env.INIT_STATE_WEEK_INFO;
    List<WorkInfo> worklist = list.workInfos;
    workTime.clear;
    if (Env.INIT_STATE_WEEK_INFO == null) {
      for (int i = 0; i < week.length; i++) {
        workTime.add("----");
        workingtime = 0;
      }
    } else {
      for (int i = 0; i < worklist.length; i++) {
        Log.debug(worklist[i].toString());

        workTime.add((worklist[i].strAttendLeaveTime!));
        weekinTime.add(worklist[i].attendtime ?? "");
        weekoutTime.add(worklist[i].leavetime ?? "");

        if (worklist[i].isweekend == "Y" || worklist[i].isholiday == "Y") {
          count++;
        }
      }
      workingtime = (7 - count) * 8;
    }

    for (int i = 0; i < week.length; i++) {
      if (weekinTime[i] == "" && weekoutTime[i] == "") {
        today[i] = false;
      } else if (weekinTime[i] != "" && weekoutTime[i] == "") {
        today[i] = true;
      } else {
        today[i] = false;
      }
    }
    setState(() {});
  }

  void _setUI(WorkInfo workInfo) {
    if (workInfo.success) {
      setState(() {
        this.workInfo = workInfo;
      });
    } else {
      workInfo = WorkInfo(1, "---", "", "", "", "", "", "", "--:--", "--:--", "--------", "", "", "", "", success: false, message: "");
    }
  }

  void _setBeaconUI(BeaconInfoData beaconInfoData) {
    this.beaconInfoData = beaconInfoData;
    setState(() {});
  }

  void _showSyncDialog(BuildContext context, {String? location, bool warning = true}) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => SyncDialog(
        currentLocation: location,
        warning: warning,
      ),
    );
  }
}
