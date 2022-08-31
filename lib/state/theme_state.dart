// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/background_service.dart';
import 'package:teragate_v3/state/widgets/coustom_businesscard.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';

class ThemeMain extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const ThemeMain(
      {required this.eventStreamController,
      required this.beaconStreamController,
      Key? key})
      : super(key: key);

  @override
  State<ThemeMain> createState() => _ThemeState();
}

class _ThemeState extends State<ThemeMain> {
  bool backgroundbool = false;

  late StreamSubscription beaconStreamSubscription;
  late StreamSubscription eventStreamSubscription;

  late SecureStorage secureStorage;

  late BeaconInfoData beaconInfoData;

  @override
  void initState() {
    super.initState();

    secureStorage = new SecureStorage();

    eventStreamSubscription =
        widget.eventStreamController.stream.listen((event) {
      if (event.isNotEmpty) {
        WorkInfo workInfo = WorkInfo.fromJson(json.decode(event));
      }
    });

    beaconStreamSubscription = startBeaconSubscription(
        widget.beaconStreamController, secureStorage, setBeaconUI);

    setUI(false);
    //Get.to(Home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
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
                              ])),
                    ],
                  )),
              Expanded(
                  flex: 7,
                  child: createContainer(Column(
                    children: [
                      Expanded(
                        flex: 10,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: "테마 배경 사용",
                                size: 16,
                                color: Colors.black,
                              ),
                              Switch(
                                  value: backgroundbool,
                                  activeColor: Colors.white,
                                  activeTrackColor: const Color(0xff26C145),
                                  inactiveTrackColor: const Color(0xff444653),
                                  onChanged: (value) {
                                    setUI(value);
                                  })
                            ]),
                      ),
                      const Expanded(flex: 7, child: SizedBox()),
                      Expanded(
                          flex: 45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              initRowByiconText("배경색 사용"),
                              Row(
                                children: [
                                  initContainerByImageBox("배경1"),
                                  initContainerByImageBox("배경2"),
                                  initContainerByImageBox("배경3"),
                                  initContainerByImageBox("배경4"),
                                ],
                              )
                            ],
                          )),
                      Expanded(
                          flex: 45,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              initRowByiconText("테마 사용"),
                              Row(
                                children: [
                                  initContainerByImageBox("테마1"),
                                  initContainerByImageBox("테마2"),
                                  initContainerByImageBox("테마3"),
                                ],
                              )
                            ],
                          ))
                    ],
                  ))),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: createContainerwhite(const CustomBusinessCard(
                          company: "주식회사 테라비전",
                          name: "홍길동",
                          position: "과장",
                          worktime: "09:00 ~ 18:00",
                          workbool: true)))),
              Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.pink,
                  ))
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {},
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.commute),
              label: 'Commute',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bookmark),
              icon: Icon(Icons.bookmark_border),
              label: 'Saved',
            ),
          ],
        ));
  }

  @override
  void dispose() {
    beaconStreamSubscription.cancel();
    eventStreamSubscription.cancel();
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
    return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: widget);
  }

  Container createContainerwhite(Widget widget) {
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: widget);
  }

//이미지 박스
  Container initContainerByImageBox(String img) {
    return Container(
      margin: EdgeInsets.all(8),
      height: 100,
      width: 50,
      child: Image.asset("assets/$img.png", fit: BoxFit.fitHeight),
    );
  }

  void setUI(bool value) {
    setState(() {
      backgroundbool = value;
    });
  }

  void setBeaconUI(BeaconInfoData beaconInfoData) {
    this.beaconInfoData = beaconInfoData;
  }

  void sendToBroadcast(WorkInfo workInfo) {
    widget.eventStreamController.add(workInfo.toString());
  }
}
