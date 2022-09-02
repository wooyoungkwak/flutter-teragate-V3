import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teragate_v3/config/env.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/utils/time_util.dart';

class CustomBusinessCard extends StatelessWidget {
  final String company = Env.KEY_COMPANY_NAME;
  final String? name = Env.WORK_KR_NAME;
  final String? position = Env.WORK_POSITION_NAME;

  CustomBusinessCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WorkInfo workInfo = Env.INIT_STATE_INFO;
    bool workbool = false;
    String worktime = "${workInfo.targetAttendTime} ~ ${workInfo.targetLeaveTime}";
    // DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    // DateTime attime =  dateFormat.parse("2019-07-19 8:40:23");
    // DateTime LeaveTime =  dateFormat.parse("2019-07-19 8:40:23");
    // getDateToString(workInfo.targetAttendTime,"kk:mm");
    // if( < getPickerTime(getNow()) < =workInfo.targetLeaveTime ){
    // } 시간 사이에 값 받아올려다가 라이브러리 찾을려함.. 번거로움
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
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CustomText(text: company, weight: FontWeight.w500, size: 14, color: Colors.black),
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
}
