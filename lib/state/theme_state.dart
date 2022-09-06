// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/background_service.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/state/widgets/bottom_navbar.dart';
import 'package:teragate_v3/state/widgets/coustom_businesscard.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/utils/alarm_util.dart';
import 'package:teragate_v3/utils/time_util.dart';
import 'package:teragate_v3/state/widgets/synchonization_dialog.dart';

class ThemeMain extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const ThemeMain({required this.eventStreamController, required this.beaconStreamController, Key? key}) : super(key: key);

  @override
  State<ThemeMain> createState() => _ThemeState();
}

class _ThemeState extends State<ThemeMain> {
  bool visibleTheme = true;
  bool isImage = false;
  List<int> indexImage = [];
  List backgrounListItems = [
    {
      "value": false,
      "image": "background1",
    },
    {
      "value": false,
      "image": "background2",
    },
    {
      "value": false,
      "image": "background3",
    },
    {
      "value": false,
      "image": "background4",
    }
  ];

  List themeListItmes = [
    {
      "value": false,
      "image": "theme1",
    },
    {
      "value": false,
      "image": "theme2",
    },
    {
      "value": false,
      "image": "theme3",
    }
  ];

  late SecureStorage secureStorage;
  late BeaconInfoData beaconInfoData;
  WorkInfo? workInfo;

  @override
  void initState() {
    super.initState();
    workInfo = Env.INIT_STATE_WORK_INFO;
    secureStorage = SecureStorage();
    Env.EVENT_FUNCTION = _setUI;
    Env.BEACON_FUNCTION = _setBeaconUI;
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return WillPopScope(
      onWillPop: () {
        MoveToBackground.moveTaskToBack();
        return Future(() => false);
      },
      child: Container(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  CustomText(
                                    text: "메인 테마 설정",
                                    size: 18,
                                    weight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: createContainer(
                          Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                CustomText(
                                  text: "테마 배경 사용",
                                  size: 16,
                                  color: Colors.black,
                                ),
                                Switch(
                                    value: visibleTheme,
                                    activeColor: Colors.white,
                                    activeTrackColor: const Color(0xff26C145),
                                    inactiveTrackColor: const Color(0xff444653),
                                    onChanged: (value) {
                                      setState(() {
                                        visibleTheme = value;
                                      });
                                      // setUI(value);
                                    })
                              ]),
                              const Expanded(flex: 7, child: SizedBox()),
                              Expanded(
                                  flex: 45,
                                  child: AnimatedOpacity(
                                    opacity: visibleTheme ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 500),
                                    child: Visibility(
                                      maintainAnimation: true,
                                      maintainState: true,
                                      visible: visibleTheme,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          initRowByiconText("배경색 사용"),
                                          Row(
                                            children: List.generate(backgrounListItems.length, (index) => initContainerByImageBox(list: backgrounListItems, index: index)),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                              Expanded(
                                flex: 45,
                                child: AnimatedOpacity(
                                  opacity: visibleTheme ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Visibility(
                                    maintainAnimation: true,
                                    maintainState: true,
                                    visible: visibleTheme,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        initRowByiconText("테마 사용"),
                                        Row(
                                          children: List.generate(themeListItmes.length, (index) => initContainerByImageBox(list: themeListItmes, index: index)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
            bottomNavigationBar: BottomNavBar(currentLocation: Env.CURRENT_PLACE, currentTime: getPickerTime(getNow()), function: _synchonizationThemeUI)),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Row initRowByiconText(String text) {
    return Row(
      children: [
        const Icon(Icons.check_box),
        CustomText(
          text: text,
          size: 14,
          weight: FontWeight.w400,
          color: Colors.black,
        ),
      ],
    );
  }

  Container createContainer(Widget widget) {
    return Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: widget);
  }

  Container createContainerwhite(Widget widget) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: widget);
  }

//이미지 박스
  Container initContainerByImageBox({required int index, required list}) {
    return Container(
      margin: EdgeInsets.all(8),
      height: 100,
      width: 50,
      decoration: list[index]["value"] ? BoxDecoration(border: Border.all(color: Color(0xff26C145), width: 5)) : null,
      child: GestureDetector(
          onTap: () {
            setState(() {
              _initListReset();
              list[index]["value"] = true;
            });
            _setBackgroundPath("${list[index]["image"]}.png");
          },
          child: Image.asset("assets/${list[index]["image"]}.png", fit: BoxFit.fitHeight)),
    );
  }

  void _setUI(WorkInfo workInfo) {
    setState(() {
      this.workInfo = workInfo;
    });
  }

  void _synchonizationThemeUI(WorkInfo? workInfo) {
    sendMessageByWork(context, secureStorage).then((workInfo) {
      if (workInfo!.success) {
        setState(() {});
        _showSyncDialog(context, location: Env.CURRENT_PLACE);
      } else {}
    });
  }

  void _showSyncDialog(BuildContext context, {String? location, String? time, bool warning = true}) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => SyncDialog(
        currentLocation: location,
        warning: warning,
      ),
    );
  }

  void _setBeaconUI(BeaconInfoData beaconInfoData) {
    this.beaconInfoData = beaconInfoData;
    setState(() {});
  }

  void sendToBroadcast(WorkInfo workInfo) {
    widget.eventStreamController.add(workInfo.toString());
  }

  void _setBackgroundPath(String path) {
    secureStorage.write(Env.KEY_BACKGROUND_PATH, path);
    Env.BACKGROUND_PATH = path;
  }

  void _initListReset() {
    for (var el in backgrounListItems) {
      el["value"] = false;
    }
    for (var el in themeListItmes) {
      el["value"] = false;
    }
  }
}
