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

  @override
  void initState() {
    super.initState();
    secureStorage = SecureStorage();
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
              children: [
                _createIconByContainer(
                  icon: Icons.home,
                  text: "홈",
                  function: () => {
                    _passNextPage(context, '/home')
                    // sendMessageByWork(context, secureStorage).then((workInfo) {
                    //   Env.INIT_STATE_WORK_INFO = workInfo;
                    // })
                  },
                ),
                _createIconByContainer(
                  icon: Icons.access_time_filled,
                  text: "출퇴근",
                  function: () => {
                    _passNextPage(context, '/week')
                    // sendMessageByWork(context, secureStorage).then((workInfo) {
                    //   Env.INIT_STATE_WORK_INFO = workInfo;
                    // })
                  },
                ),
                _createIconByContainer(
                  icon: Icons.refresh,
                  color: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 60, 95, 235),
                  text: "동기화",
                  function: () => {widget.function == null ? "" : widget.function!(null)},
                ),
                _createIconByContainer(
                    icon: Icons.camera,
                    text: "테마",
                    function: () => {
                          _passNextPage(context, '/theme'),
                          // sendMessageByWork(context, secureStorage).then((workInfo) {
                          //   Env.INIT_STATE_WORK_INFO = workInfo;
                          // })
                        }),
                _createIconByContainer(
                    icon: Icons.place_rounded,
                    text: "등록",
                    function: () => {
                          _passNextPage(context, '/place'),
                          // sendMessageByWork(context, secureStorage).then((workInfo) {
                          //   Env.INIT_STATE_WORK_INFO = workInfo;
                          // })
                        }),
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
}
