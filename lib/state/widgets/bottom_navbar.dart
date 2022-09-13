import 'package:flutter/material.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/storage_model.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/services/server_service.dart';
import 'package:teragate_v3/utils/log_util.dart';

class BottomNavBar extends StatefulWidget {
  final String? currentLocation;
  final String? currentTime;
  final Function? function;

  const BottomNavBar({this.currentLocation, this.currentTime, this.function, Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late SecureStorage secureStorage;
  List navigatorItem = [
    {
      "selected": false,
      "icon": Icons.home,
      "text": "홈",
      "path": '/home',
    },
    {
      "selected": false,
      "icon": Icons.access_time_filled,
      "text": "출퇴근",
      "path": '/week',
    },
    {
      "selected": true,
      "icon": Icons.refresh,
      "text": "동기화",
      "path": "",
    },
    {
      "selected": false,
      "icon": Icons.camera,
      "text": "테마",
      "path": '/theme',
    },
    {
      "selected": false,
      "icon": Icons.place_rounded,
      "text": "등록",
      "path": '/place',
    },
  ];

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();
    navigatorItem[Env.CURRENT_PAGE_INDEX]["selected"] = true;
  }

  @override
  Widget build(BuildContext context) {
    var paddingSize = (MediaQuery.of(context).size.width - 211) / 2;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 138.0,
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
                      text: _textIncision(widget.currentLocation == "" || widget.currentLocation == null ? "---" : widget.currentLocation!),
                      size: 12.0,
                      color: Colors.black,
                      weight: FontWeight.bold,
                      isOverlfow: true,
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
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                navigatorItem.length,
                (index) => _createIconByContainer(
                  selectedIcon: navigatorItem[index]["selected"],
                  icon: navigatorItem[index]["icon"],
                  text: navigatorItem[index]["text"],
                  function: () => {
                    if (navigatorItem[index]["path"] == "")
                      {widget.function == null ? "" : widget.function!(null)}
                    else
                      {
                        Env.CURRENT_PAGE_INDEX = index,
                        _passNextPage(context, navigatorItem[index]["path"]),
                      }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _createIconByContainer({
    bool selectedIcon = false,
    IconData? icon,
    Color color = const Color.fromARGB(255, 60, 95, 235),
    Color backgroundColor = Colors.white,
    String? text,
    VoidCallback? function,
  }) {
    backgroundColor = icon == Icons.refresh
        ? const Color.fromARGB(255, 60, 95, 235)
        : selectedIcon
            ? const Color.fromARGB(110, 60, 95, 235)
            : Colors.white;
    color = selectedIcon ? Colors.white : const Color.fromARGB(255, 60, 95, 235);

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
          onTap: function ??
              () {
                Log.debug("Callback 함수 미실행");
              },
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

  void _passNextPage(BuildContext context, String pushName) {
    if (ModalRoute.of(context)!.settings.name != pushName) {
      Navigator.pushNamedAndRemoveUntil(context, pushName, (route) {
        sendMessageByWork(context, secureStorage).then((workInfo) {
          Env.INIT_STATE_WORK_INFO = workInfo;
        });
        return false;
      });
    }
  }

  String _textIncision(String text) {
    if (text.length > 6) {
      text = "${text.substring(0, 5)}...";
    }
    return text;
  }

  // void selectedPage() {
  //   if (_currentIndex == index) {
  //     navigatorItem[_currentIndex]["selected"] = true;
  //   }
  // }
}
