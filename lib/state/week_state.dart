import 'package:flutter/material.dart';
import 'package:teragate_v3/state/place_state.dart';
import 'package:teragate_v3/state/widgets/coustom_businesscard.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:get/get.dart';

class Week extends StatefulWidget {
  const Week({Key? key}) : super(key: key);
  State<Week> createState() => _WeekState();
}

class _WeekState extends State<Week> {
  int worktime = 32;
  List<String> week = [];
  List<String> weekTime = [];
  List<String> weekinTime = [];
  List<String> weekoutTime = [];
  List<bool> workinOk = []; // 정상 출근 true/ 지각 false
  List<bool> workoutOk = []; // 정상 출근 true/ 조기퇴근 false
  List<bool> today = []; // 오늘날짜 색 변경 변수 이름이 떠오르지않음...

  @override
  void initState() {
    super.initState();
    setUI();
    //Get.to(Home);
  }

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(Controller());
    // controller.increment();

    return _createWillPopScope(Scaffold(
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
                                  text: "금주 출퇴근 시간",
                                  size: 18,
                                  weight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ])),
                    ],
                  )),
              Expanded(
                  flex: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      initListView(),
                      // Obx(() => Text("TEXT: ${controller.location}")),
                      // Obx(() => Text("TEXT: ${controller.week}")),
                      // Obx(() => Text("${controller.weekData["week"]}")),
                      Row(
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
                      )
                    ],
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      child: _createContainerwhite(const CustomBusinessCard(
                          company: "주식회사 테라비전",
                          name: "홍길동",
                          position: "과장",
                          worktime: "09:00 ~ 18:00",
                          workbool: true)))),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Place()));
          },
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
        )));
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
  Container initContainerByweektext(
      Color color, String week, String worktime, bool today) {
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
            CustomText(text: worktime, size: 13, color: Colors.black)
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
              weekTime[i],
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
    setState(() {
      week = ["일", "월", "화", "수", "목", "금", "토"];
      worktime = 40;
      weekTime = [
        "휴일",
        "08:30~16:00",
        "08:30~16:00",
        "08:30~16:00",
        "08:30~16:00",
        "08:30~16:00",
        "휴일"
      ];
      weekinTime = [
        "",
        "08:30",
        "08:30",
        "08:30",
        "",
        "08:30",
        "08:30",
      ];
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
}
