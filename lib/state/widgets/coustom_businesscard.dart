import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/utils/time_util.dart';

class CustomBusinessCard extends StatelessWidget {
  final String? company = Env.WORK_COMPANY_NAME;
  final String? name = Env.WORK_KR_NAME;
  final String? position = Env.WORK_POSITION_NAME;
  WorkInfo? workInfo;
  CustomBusinessCard(this.workInfo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool workbool = false;
    workInfo = workInfo ?? WorkInfo(1, "---", "", "", "", "", "", "", "--:--", "--:--", "", "", "", "", "", success: false, message: "");
    String worktime = "${workInfo!.targetAttendTime} ~ ${workInfo!.targetLeaveTime}";
    workbool = true;
    String profilePicture = Env.WORK_PHOTO_PATH!;

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                //에러핸들러 추가 [나중에 통합할때 변경]
                profilePicture,
                errorBuilder: ((context, error, stackTrace) => _errorImage()),
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomText(text: company!, weight: FontWeight.w500, size: 14, color: Colors.black),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: name!,
                      size: 24,
                      weight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    CustomText(
                      text: position!,
                      weight: FontWeight.w400,
                      size: 14,
                      color: Colors.black,
                    ),
                  ],
                )
              ]),
            )
          ],
        ),
        workbool == true
            ? _createContainer(const Center(child: CustomText(text: "업무중", size: 16, weight: FontWeight.w500)))
            : _createContainer(
                const Center(child: CustomText(text: "업무종료", size: 16, weight: FontWeight.w500)),
              )
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomText(
          text: DateTime.now().toString(),
          size: 14,
          color: const Color(0xff3C5FEB),
          weight: FontWeight.w500,
        ),
        CustomText(text: worktime, weight: FontWeight.w400, size: 14, color: Colors.black),
      ])
    ]);
  }

  Container _createContainer(Widget widget) {
    return Container(
        margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xff3C5FEB), borderRadius: BorderRadius.circular(6)), child: widget);
  }

  Image _errorImage() {
    return Image.network(
      "https://st4.depositphotos.com/1012074/20946/v/450/depositphotos_209469984-stock-illustration-flat-isolated-vector-illustration-icon.jpg",
      fit: BoxFit.cover,
      width: 48,
      height: 48,
    );
  }
}
