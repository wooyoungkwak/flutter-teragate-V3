import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teragate_v3/State/widgets/custom_text.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/state/theme_state.dart';
import 'dart:convert';
import 'package:teragate_v3/services/background_service.dart';
import 'package:teragate_v3/state/widgets/bottom_navbar.dart';
import 'package:teragate_v3/state/widgets/coustom_Businesscard.dart';
import 'package:teragate_v3/utils/log_util.dart';

class Place extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const Place({required this.eventStreamController, required this.beaconStreamController, Key? key}) : super(key: key);
  // final controller = Get.put(Controller());
  @override
  State<Place> createState() => _HomeState();
}

class _HomeState extends State<Place> {
  List<String> locationlist = ["사무실", "휴게실", "기업부설연구소", "현장", "재고창고"];
  List<bool> locationlistbool = [false, true, false, false, false];

  late StreamSubscription beaconStreamSubscription;
  late StreamSubscription eventStreamSubscription;

  late BeaconInfoData beaconInfoData;
  late SecureStorage secureStorage;

  String currentTimeHHMM = "";
  String currentLocation = "";

  @override
  void initState() {
    super.initState();

    secureStorage = SecureStorage();

    eventStreamSubscription = widget.eventStreamController.stream.listen((event) {
      if (event.isNotEmpty) {
        WorkInfo workInfo = WorkInfo.fromJsonByState(json.decode(event));
      }
    });

    beaconStreamSubscription = startBeaconSubscription(widget.beaconStreamController, secureStorage, setBeaconUI);

    setUI();
    //Get.to(Home);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
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
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
                                margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
                                padding: const EdgeInsets.only(top: 15),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                  CustomText(
                                    text: "등록 단말기 정보",
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
                              flex: 5,
                              child: initGridView(locationlist, locationlistbool),
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CustomText(
                                      text: "신규등록한 단말기가 보이지 않을 경우",
                                      size: 12,
                                      weight: FontWeight.w400,
                                      color: Color(0xff6E6C6C),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: CustomText(
                                        text: "하단 동기화 버튼을 눌러주세요",
                                        size: 12,
                                        weight: FontWeight.w400,
                                        color: Color(0xff6E6C6C),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ))),
                    Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(8), child: createContainerwhite(const CustomBusinessCard(company: "주식회사 테라비전", name: "홍길동", position: "과장", worktime: "09:00 ~ 18:00", workbool: true)))),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentLocation: currentLocation,
            currentTime: currentTimeHHMM,
          )),
    ));
  }

  @override
  void dispose() {
    beaconStreamSubscription.cancel();
    eventStreamSubscription.cancel();
    super.dispose();
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future(() => false);
        },
        child: widget);
  }

  Container createContainer(Widget widget) {
    return Container(margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: widget);
  }

  Container createContainerwhite(Widget widget) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: widget);
  }

  GridView initGridView(List list, List listbool) {
    return GridView.builder(
        itemCount: list.length, //item 개수
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
          childAspectRatio: 1 / 1, //item 의 가로 1, 세로 2 의 비율
          mainAxisSpacing: 10, //수평 Padding
          crossAxisSpacing: 10, //수직 Padding
        ),
        itemBuilder: ((context, index) {
          return Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xffF5F5F5), borderRadius: BorderRadius.circular(8)),
              child: Stack(alignment: Alignment.topLeft, children: [
                listbool[index] == true
                    ? const Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 10,
                      )
                    : Container(),
                Center(
                    child: Align(
                        alignment: Alignment.center,
                        child: CustomText(
                          text: list[index],
                          size: 16,
                          weight: FontWeight.bold,
                          color: Colors.black,
                        )))
              ]));
        }));
  }

  void setUI() {
    //  비콘 정보 요청 ( 동기화 )
    sendMessageByBeacon(context, secureStorage).then((configInfo) {
      List<BeaconInfoData> placeInfo = configInfo!.beaconInfoDatas;
      Log.debug(" placeInfo === ${configInfo.message.toString()} ");
      Log.debug(" placeInfo === ${configInfo.beaconInfoDatas.toString()} ");
    });

    currentTimeHHMM = "19:30";
    currentLocation = "사무실";
    setState(() {
      String location = "기업부설연구소";
      locationlist = ["사무실", "휴게실", "기업부설연구소", "현장", "재고창고"];
      locationlistbool = [false, false, false, false, false, false, false, false, false, false];
      for (int i = 0; i < locationlist.length; i++) {
        if (location == locationlist[i]) {
          locationlistbool[i] = true;
        } else {
          locationlistbool[i] = false;
        }
      }
    });
  }

  void setBeaconUI(BeaconInfoData beaconInfoData) {
    Log.debug(" beaconInfoData = ${beaconInfoData.toString()}");
    this.beaconInfoData = beaconInfoData;
  }
}
