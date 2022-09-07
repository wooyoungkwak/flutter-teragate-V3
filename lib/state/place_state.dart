import 'dart:async';
import 'package:flutter/material.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:teragate_v3/State/widgets/custom_text.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/state/theme_state.dart';
import 'dart:convert';
import 'package:teragate_v3/services/background_service.dart';
import 'package:teragate_v3/state/widgets/bottom_navbar.dart';
import 'package:teragate_v3/state/widgets/coustom_Businesscard.dart';
import 'package:teragate_v3/state/widgets/synchonization_dialog.dart';
import 'package:teragate_v3/utils/alarm_util.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

class Place extends StatefulWidget {
  final StreamController eventStreamController;
  final StreamController beaconStreamController;

  const Place({required this.eventStreamController, required this.beaconStreamController, Key? key}) : super(key: key);

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  List<String> placeList = [""];
  late SimpleFontelicoProgressDialog dialog;
  BeaconInfoData beaconInfoData = BeaconInfoData(uuid: "", place: "");
  late SecureStorage secureStorage;
  WorkInfo? workInfo;

  @override
  void initState() {
    secureStorage = SecureStorage();
    _initUUIDList();

    workInfo = Env.INIT_STATE_WORK_INFO;
    Env.EVENT_FUNCTION = _setUI;
    Env.BEACON_FUNCTION = _setBeaconUI;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    dialog = SimpleFontelicoProgressDialog(context: context, barrierDimisable: false, duration: const Duration(milliseconds: 3000));
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
                            Expanded(flex: 5, child: placeList == null ? SizedBox() : initGridView(placeList)),
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
            function: _synchonizationPlaceUI,
          )),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          MoveToBackground.moveTaskToBack();
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

  GridView initGridView(List list) {
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
                Env.CURRENT_PLACE == ""
                    ? Container()
                    : (Env.CURRENT_PLACE == list[index]
                        ? const Icon(
                            Icons.location_on_rounded,
                            color: Colors.red,
                            size: 10,
                          )
                        : Container()),
                Center(
                    child: Align(
                        alignment: Alignment.center,
                        child: CustomText(
                          text: list[index],
                          size: 12,
                          weight: FontWeight.bold,
                          color: Colors.black,
                          isOverlfow: false,
                        )))
              ]));
        }));
  }

  void _setUI(WorkInfo workInfo) {
    setState(() {
      this.workInfo = workInfo;
    });
  }

  Future<void> _synchonizationPlaceUI(WorkInfo? workInfo) async {
    //  비콘 정보 요청 ( 동기화 )
    List<String> SharedStorageuuid = [];
    dialog.show(message: "로딩중...");
    sendMessageByBeacon(context, secureStorage).then((configInfo) {
      if (configInfo!.success!) {
        List<BeaconInfoData> placeInfo = configInfo.beaconInfoDatas;

        for (BeaconInfoData beaconInfoData in placeInfo) {
          secureStorage.write(beaconInfoData.uuid, beaconInfoData.place);
          SharedStorageuuid.add(beaconInfoData.uuid);
        }
        SharedStorage.write(Env.KEY_SHARE_UUID, SharedStorageuuid);

        setState(() {
          placeList = _deduplication(Env.UUIDS.entries.map((e) => e.value).toList());
        });
        dialog.hide();
        // _showSyncDialog(context);
      } else {
        dialog.hide();
        // _showSyncDialog(context, warning: false);
      }
    });
  }

  void _initUUIDList() async {
    setState(() {
      placeList = _deduplication(Env.UUIDS.entries.map((e) => e.value).toList());
    });
  }

  void _setBeaconUI(BeaconInfoData beaconInfoData) {
    this.beaconInfoData = beaconInfoData;
    setState(() {});
  }

  List<String> _deduplication(List<String> list) {
    var deduplicationlist = list.toSet();
    list = deduplicationlist.toList();
    return list;
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
