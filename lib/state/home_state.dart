import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:flutter/material.dart';
import 'package:teragate_v3/state/widgets/bottom_navbar.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/state/widgets/synchonization_dialog.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/utils/alarm_util.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';
import 'package:teragate_v3/services/server_service.dart';

class Home extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const Home({required this.eventStreamController, required this.beaconStreamController, Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // late StreamSubscription beaconStreamSubscription;
  // late StreamSubscription eventStreamSubscription;
  late SimpleFontelicoProgressDialog dialog;

  late BeaconInfoData beaconInfoData;

  late SecureStorage secureStorage;

  String backgroundPath = "";
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
  bool isAttendTimeOut = false;
  bool isLeave = false;

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    profilePicture = Env.WORK_PHOTO_PATH ?? "assets/workon_logo.png";

    Env.EVENT_FUNCTION = _setUI;
    Env.BEACON_FUNCTION = setBeaconUI;
    _initUI();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable: false, duration: const Duration(milliseconds: 3000));

    return WillPopScope(
      onWillPop: () {
        MoveToBackground.moveTaskToBack();
        return Future(() => false);
      },
      child: Container(
        // 배경화면
        padding: EdgeInsets.only(top: statusBarHeight),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: backgroundPath.startsWith("/data")
                ? FileImage(File(backgroundPath))
                : backgroundPath.toString().startsWith('/private')
                    ? FileImage(File(backgroundPath))
                    : AssetImage("assets/$backgroundPath") as ImageProvider,
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
                          showLogoutDialog(context);
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
                              errorBuilder: ((context, error, stackTrace) => _errorImage()),
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
                              child: _createButtonByPadding(
                                color: _setGetInColor(getInTime),
                                title: "출근",
                                time: getInTime,
                                action: getIn,
                              )),
                          Expanded(
                              flex: 2,
                              child: _createButtonByPadding(
                                color: _setGetOutColor(getOutTime),
                                title: "퇴근",
                                time: getOutTime,
                                action: getOut,
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
            currentLocation: Env.CURRENT_PLACE,
            currentTime: getPickerTime(getNow()),
            function: _syncghoniztionHomeUI,
          ),
        ),
      ),
    );
  }

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
              size: 16.0,
              color: color == Colors.white ? Colors.black : Colors.white,
            ),
            if (currentTime != null)
              CustomText(
                padding: const EdgeInsets.all(5.0),
                text: "현재시간 : $currentTime",
                size: 13.0,
                color: color == Colors.white ? Colors.black : Colors.white,
                weight: FontWeight.w400,
              ),
          ],
        ),
      ),
    );
  }

  Padding _createButtonByPadding({
    Color color = Colors.white,
    String? title,
    String? time,
    var action,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () {
            action();
          },
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
                  size: 16.0,
                  color: color == Colors.white ? Colors.black : Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Image _errorImage() {
    Log.debug(" errorImage ... ");
    return Image.asset(
      "assets/workon_logo.png",
      fit: BoxFit.scaleDown,
      width: 48,
      height: 48,
    );
  }

  Color _setWorkStateColor(String workState) {
    if (workState == "업무중") {
      return const Color(0xff25A45F);
    } else {
      return Colors.white;
    }
  }

  Color _setGetInColor(String getInTime) {
    if (getInTime != "-") {
      return const Color(0xff3C5FEB);
    } else if (isAttendTimeOut) {
      return const Color(0xff7C8298);
    } else {
      return Colors.white;
    }
  }

  Color _setGetOutColor(String getOutTime) {
    if (isLeave) {
      return const Color(0xffFF3823);
    } else {
      return Colors.white;
    }
  }

  void setBeaconUI(BeaconInfoData beaconInfoData) {
    this.beaconInfoData = beaconInfoData;

    setState(() {
      if (this.beaconInfoData == null) {
        currentLocation = "---";
      } else {
        currentLocation = beaconInfoData.place;
        currentTimeHHMM = getPickerTime(getNow());
      }
    });
  }

  void _initUI() {
    Map<String, dynamic> setInfoMap = getWorkState(Env.INIT_STATE_WORK_INFO);

    setState(() {
      // 시간
      currentHour = getDateToStringForHHInNow();
      currentMinute = getDateToStringForMMInNow();
      currentDay = "${getDateToStringForMMDDKORInNow()} ${getWeekByKor()}";
      currentTimeHHMM = getDateToStringForHHMMInNow();
      // 프로필
      company = Env.WORK_COMPANY_NAME ?? "-";
      profilePicture = Env.WORK_PHOTO_PATH ?? "assets/workon_logo.png";
      profileName = Env.WORK_KR_NAME ?? "---";
      profilePosition = Env.WORK_POSITION_NAME ?? "-";
      // 상태
      workState = setInfoMap["state"];
      isAttendTimeOut = setInfoMap["isAttendTimeOut"];
      isLeave = setInfoMap["isLeaveTime"];
      workTime = Env.INIT_STATE_WORK_INFO.strAttendLeaveTime ?? "-";
      getInTime = Env.INIT_STATE_WORK_INFO.attendtime ?? "-";
      getOutTime = Env.INIT_STATE_WORK_INFO.leavetime ?? "-";
      // 현재위치
      currentLocation = Env.INIT_STATE_WORK_INFO.placeWorkName ?? "-";
      // 배경화면
      backgroundPath = Env.BACKGROUND_PATH ?? "background1.png";
    });
  }

  void _setUI(WorkInfo workInfo) {
    if (workInfo.success) {
      Map<String, dynamic> setInfoMap = getWorkState(workInfo);
      setState(() {
        // 시간
        currentHour = getDateToStringForHHInNow();
        currentMinute = getDateToStringForMMInNow();
        currentDay = "${getDateToStringForMMDDKORInNow()} ${getWeekByKor()}";
        currentTimeHHMM = getDateToStringForHHMMInNow();
        // 상태
        workState = setInfoMap["state"];
        isAttendTimeOut = setInfoMap["isAttendTimeOut"];
        isLeave = setInfoMap["isLeaveTime"];
        workTime = workInfo.strAttendLeaveTime ?? "-";
        getInTime = workInfo.attendtime ?? "-";
        getOutTime = workInfo.leavetime ?? "-";
        currentLocation = workInfo.placeWorkName ?? "-";
      });
    }
  }

  Future<void> _syncghoniztionHomeUI(WorkInfo? workInfo) async {
    dialog.show(message: "로딩중...");
    sendMessageByWork(context, secureStorage).then((workInfo) {
      if (workInfo!.success) {
        _resetState(workInfo);
        dialog.hide();
        showSyncDialog(context,
            widget: SyncDialog(
              currentLocation: Env.CURRENT_PLACE,
              warning: true,
            ));
      } else {
        dialog.hide();
        showSyncDialog(context,
            widget: SyncDialog(
              currentLocation: null,
              warning: false,
            ));
      }
    });
  }

  Future<void> getIn() async {
    dialog.show(message: "로딩중...");

    sendMessageByGetIn(context, secureStorage).then((workInfo) {
      if (workInfo!.success) {
        dialog.hide();
        showSyncDialog(
          context,
          widget: SyncDialog(
            text: "출근이 완료되었습니다.",
          ),
        );
      } else {
        dialog.hide();
        showSyncDialog(
          context,
          widget: SyncDialog(
            text: "이미 출근을 하셨습니다.",
          ),
        );
      }

      sendMessageByWork(context, secureStorage).then((workInfo) {
        if (workInfo!.success) {
          _resetState(workInfo);
        }
      });
    });
  }

  Future<void> getOut() async {
    dialog.show(message: "로딩중...");
    sendMessageByGetOut(context, secureStorage).then((workInfo) {
      if (workInfo!.success) {
        dialog.hide();
        showSyncDialog(
          context,
          widget: SyncDialog(
            text: "퇴근이 완료되었습니다.",
          ),
        );
      }

      sendMessageByWork(context, secureStorage).then((workInfo) {
        if (workInfo!.success) {
          _resetState(workInfo);
        }
      });
    });
  }

  void _resetState(WorkInfo workInfo) {
    Map<String, dynamic> setInfoMap = getWorkState(workInfo);
    setState(() {
      // 시간
      currentHour = getDateToStringForHHInNow();
      currentMinute = getDateToStringForMMInNow();
      currentDay = "${getDateToStringForMMDDKORInNow()} ${getWeekByKor()}";
      currentTimeHHMM = getDateToStringForHHMMInNow();
      // 상태
      workState = setInfoMap["state"];
      isAttendTimeOut = setInfoMap["isAttendTimeOut"];
      isLeave = setInfoMap["isLeaveTime"];
      workTime = workInfo.strAttendLeaveTime ?? "-";
      getInTime = workInfo.attendtime ?? "-";
      getOutTime = workInfo.leavetime ?? "-";
    });
  }
}
