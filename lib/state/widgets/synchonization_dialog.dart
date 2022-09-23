import 'package:flutter/material.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/utils/log_util.dart';
import 'package:teragate_v3/utils/time_util.dart';

class SyncDialog extends StatelessWidget {
  String? text;
  String? currentLocation;
  bool warning;
  SyncDialog({this.text, this.currentLocation, this.warning = true, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: warning
                  ? _createIconByContainer(icon: Icons.replay_outlined, color: Colors.white, backgroundColor: const Color.fromARGB(255, 60, 95, 235))
                  : _createIconByContainer(icon: Icons.error, color: Colors.white, backgroundColor: const Color(0xffFF3823)),
            ),
            if (!warning || text != null) const SizedBox(height: 40.0),
            // Title
            CustomText(
              padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
              text: text != null
                  ? text!
                  : warning
                      ? "시스템을 동기화 하였습니다."
                      : "시스템 동기화에 실패 하였습니다.",
              size: 20.0,
              color: Colors.black,
            ),
            // 위치, 시간
            if (warning && text == null)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    currentLocation == null ? const SizedBox() : (currentLocation == "" ? const SizedBox() : _createSyncInfomationbyRow("위치", currentLocation!)),
                    _createSyncInfomationbyRow("시간", getPickerTime(getNow())),
                  ],
                ),
              ),
            // 메세지
            if (warning && text == null)
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

  Container _createIconByContainer({
    IconData? icon,
    Color color = const Color.fromARGB(255, 60, 95, 235),
    Color backgroundColor = Colors.white,
    String? text,
    VoidCallback? function,
  }) {
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
}
