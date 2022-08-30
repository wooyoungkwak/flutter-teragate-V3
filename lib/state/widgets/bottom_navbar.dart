import 'package:flutter/material.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';

class BottomNavBar extends StatelessWidget {
  final String? currentLocation;
  final String? currentTime;

  const BottomNavBar({this.currentLocation, this.currentTime, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var paddingSize = (MediaQuery.of(context).size.width - 211) / 2;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 140.0,
      ),
      child: Column(
        children: [
          // 현재 위치
          Padding(
            padding: EdgeInsets.only(
              bottom: 10.0,
              left: paddingSize,
              right: paddingSize,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Icons.place,
                        size: 20.0,
                      ),
                    ),
                    const CustomText(
                      text: "현재 위치는 ",
                      size: 10.0,
                      color: Colors.black,
                      weight: FontWeight.w500,
                    ),
                    CustomText(
                      text: currentLocation!,
                      size: 12.0,
                      color: Colors.black,
                      weight: FontWeight.bold,
                    ),
                    const CustomText(
                      text: " 입니다.",
                      size: 10.0,
                      color: Colors.black,
                      weight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // bottom button
          Container(
            height: 90.0,
            padding: const EdgeInsets.only(bottom: 20.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _createIconByContainer(
                  icon: Icons.home,
                  text: "홈",
                  function: () => {
                    _passNextPage(context, '/home'),
                  },
                ),
                _createIconByContainer(
                  icon: Icons.access_time_filled,
                  text: "출퇴근",
                  function: () => {
                    _passNextPage(context, '/week'),
                  },
                ),
                _createIconByContainer(
                  icon: Icons.refresh,
                  color: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 60, 95, 235),
                  text: "동기화",
                  function: () => showSyncDialog(context),
                ),
                _createIconByContainer(
                  icon: Icons.camera,
                  text: "테마",
                ),
                _createIconByContainer(
                    icon: Icons.place_rounded,
                    text: "등록",
                    function: () => {Navigator.pop(context)}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _createIconByContainer({
    IconData? icon,
    Color color = const Color.fromARGB(255, 60, 95, 235),
    Color backgroundColor = Colors.white,
    String? text,
    VoidCallback? function,
  }) {
    var iconColor = const Color.fromARGB(255, 60, 95, 235); // 전역 스타일 변수로 선언할것
    color = backgroundColor != iconColor ? iconColor : Colors.white;

    return Container(
      height: 60.0,
      width: 60.0,
      margin: const EdgeInsets.only(left: 5.0, right: 5.0),
      // padding: const EdgeInsets.all(1.0),
      child: Material(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
        child: InkWell(
          onTap: function ?? () {},
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
              ),
              if (text != null)
                CustomText(
                  text: text,
                  size: 12.0,
                  color: color,
                  weight: FontWeight.w400,
                )
            ],
          ),
        ),
      ),
    );
  }

  Dialog _initDialog(String currentLocation, String currentTime) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: SizedBox(
        width: 378.0,
        height: 310.0,
        child: Column(
          children: [
            // 아이콘
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: _createIconByContainer(
                  icon: Icons.replay_outlined,
                  backgroundColor: const Color.fromARGB(255, 60, 95, 235)),
            ),
            // Title
            const CustomText(
              padding: EdgeInsets.only(top: 2.0, bottom: 10.0),
              text: "시스템을 동기화 하였습니다.",
              size: 20.0,
              color: Colors.black,
            ),
            // 위치, 시간
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _createSyncInfomationbyRow("위치", currentLocation),
                  _createSyncInfomationbyRow("시간", currentTime),
                ],
              ),
            ),
            // 메세지
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  _createMessageByCustomText("새로운 설정을 가져왔습니다."),
                  _createMessageByCustomText("업무 시간이 수정되었습니다."),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  CustomText _createMessageByCustomText(String message) {
    return CustomText(
      padding: const EdgeInsets.all(5.0),
      text: message,
      size: 16.0,
      weight: FontWeight.w400,
      color: const Color.fromARGB(255, 119, 120, 123),
    );
  }

  Row _createSyncInfomationbyRow(String infomation, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          padding: const EdgeInsets.only(right: 5.0),
          text: infomation,
          weight: FontWeight.w400,
          color: Colors.black,
        ),
        CustomText(
          text: data,
          color: const Color.fromARGB(255, 60, 95, 235),
        )
      ],
    );
  }

  void showSyncDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          _initDialog(currentLocation!, currentTime!),
    );
  }

  void _passNextPage(BuildContext context, String pushName) {
    if (ModalRoute.of(context)!.settings.name != pushName) {
      Navigator.pushNamedAndRemoveUntil(context, pushName, (route) => false);
    }
  }
}
