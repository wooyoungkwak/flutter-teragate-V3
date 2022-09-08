import 'dart:async';

import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/state/widgets/bottom_navbar.dart';
import 'package:teragate_v3/state/widgets/coustom_businesscard.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/utils/alarm_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

class ThemeMain extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const ThemeMain({required this.eventStreamController, required this.beaconStreamController, Key? key}) : super(key: key);

  @override
  State<ThemeMain> createState() => _ThemeState();
}

class _ThemeState extends State<ThemeMain> {
  late SimpleFontelicoProgressDialog dialog;
  late bool _isCheckedTheme;
  late bool _isCheckedBackground;
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
    _isCheckedBackground = Env.CHECKED_BACKGOURND;
    _isCheckedTheme = Env.CHECKED_THEME;
    _checkSelectedBackground();
  }

  @override
  Widget build(BuildContext context) {
    dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable: false, duration: const Duration(milliseconds: 3000));
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
                      // 헤더
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
                      // 테마 변경
                      Expanded(
                        flex: 7,
                        child: createContainer(
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const CustomText(
                                    text: "테마 배경 사용",
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  Switch(
                                      value: true, // 항상 켜짐(기능은 비활성화)
                                      activeColor: Colors.white,
                                      activeTrackColor: const Color(0xff26C145),
                                      inactiveTrackColor: const Color(0xff444653),
                                      onChanged: (value) {})
                                ],
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.all(0.0),
                                  shrinkWrap: true,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                                activeColor: const Color(0xffF5F5F5),
                                                checkColor: Colors.black,
                                                value: _isCheckedBackground,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _isCheckedBackground = value!;
                                                  });
                                                  Env.CHECKED_BACKGOURND = value!;
                                                }),
                                            const CustomText(
                                              text: "배경색 사용",
                                              size: 14,
                                              weight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                        AnimatedOpacity(
                                          opacity: _isCheckedBackground ? 1.0 : 0.0,
                                          duration: const Duration(milliseconds: 500),
                                          child: Visibility(
                                            maintainAnimation: true,
                                            maintainState: true,
                                            visible: _isCheckedBackground,
                                            child: Row(
                                              children: List.generate(backgrounListItems.length, (index) => initContainerByImageBox(list: backgrounListItems, index: index)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                                activeColor: const Color(0xffF5F5F5),
                                                checkColor: Colors.black,
                                                value: _isCheckedTheme,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _isCheckedTheme = value!;
                                                  });
                                                  Env.CHECKED_THEME = value!;
                                                }),
                                            const CustomText(
                                              text: "테마 사용",
                                              size: 14,
                                              weight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                        AnimatedOpacity(
                                          opacity: _isCheckedTheme ? 1.0 : 0.0,
                                          duration: const Duration(milliseconds: 500),
                                          child: Visibility(
                                            maintainAnimation: true,
                                            maintainState: true,
                                            visible: _isCheckedTheme,
                                            child: Row(
                                              children: List.generate(themeListItmes.length, (index) => initContainerByImageBox(list: themeListItmes, index: index)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 프로필
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.only(top: 8),
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

  Container createContainer(Widget widget) {
    return Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: widget);
  }

  Container createContainerwhite(Widget widget) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: widget);
  }

  //이미지 박스
  Container initContainerByImageBox({required int index, required list}) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 100,
      width: 50,
      decoration: list[index]["value"] ? BoxDecoration(border: Border.all(color: const Color(0xff26C145), width: 5)) : null,
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
    dialog.show(message: "로딩중...");
    sendMessageByWork(context, secureStorage).then((workInfo) {
      if (workInfo!.success) {
        setState(() {});
        dialog.hide();
      } else {
        dialog.hide();
      }
    });
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

  void _checkSelectedBackground() {
    for (var el in backgrounListItems) {
      if (Env.BACKGROUND_PATH?.replaceAll(".png", "") == el["image"]) {
        el["value"] = true;
        _isCheckedBackground = false;
      }
    }
    for (var el in themeListItmes) {
      if (Env.BACKGROUND_PATH?.replaceAll(".png", "") == el["image"]) {
        el["value"] = true;
        _isCheckedTheme = false;
      }
    }
  }
}
