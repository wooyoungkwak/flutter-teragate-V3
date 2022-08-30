import 'package:flutter/material.dart';
import 'package:flutter_test_ui/State/widgets/custom_text.dart';
import 'package:flutter_test_ui/state/tema_state.dart';
import 'package:flutter_test_ui/state/widgets/coustom_Businesscard.dart';

class Place extends StatefulWidget {
  const Place({Key? key}) : super(key: key);
  // final controller = Get.put(Controller());
  @override
  State<Place> createState() => _HomeState();
}

class _HomeState extends State<Place> {
  List<String> locationlist = ["사무실", "휴게실", "기업부설연구소", "현장", "재고창고"];
  List<bool> locationlistbool = [false, true, false, false, false];

  @override
  void initState() {
    super.initState();
    setUI();
    //Get.to(Home);
  }

  @override
  Widget build(BuildContext context) {
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
          onDestinationSelected: (int index) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Tema()));
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

  WillPopScope _createWillPopScope(Widget widget) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future(() => false);
        },
        child: widget);
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
              decoration: BoxDecoration(
                  color: const Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(8)),
              child: Stack(alignment: Alignment.topLeft, children: [
                listbool[index] == true
                    ? const Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
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
    setState(() {
      String location = "기업부설연구소";
      locationlist = ["사무실", "휴게실", "기업부설연구소", "현장", "재고창고"];
      locationlistbool = [
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ];
      for (int i = 0; i < locationlist.length; i++) {
        if (location == locationlist[i]) {
          locationlistbool[i] = true;
        } else {
          locationlistbool[i] = false;
        }
      }
    });
  }
}
