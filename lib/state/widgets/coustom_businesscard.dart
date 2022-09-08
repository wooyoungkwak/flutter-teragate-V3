import 'package:flutter/material.dart';
import 'package:teragate_v3/models/result_model.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';
import 'package:teragate_v3/utils/time_util.dart';

class CustomBusinessCard extends StatelessWidget {
  final String? company;
  final String? name;
  final String? position;
  final String? profilePicture;
  WorkInfo? workInfo;

  CustomBusinessCard(this.company, this.name, this.position, this.profilePicture, this.workInfo, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    workInfo = workInfo ?? WorkInfo(1, "---", "", "", "", "", "", "", "--:--", "--:--", "--------", "", "", "", "", success: false, message: "");
    Map<String, dynamic> setInfoMap = getWorkState(workInfo!);

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                profilePicture!,
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
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Row(
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
                  ),
                )
              ]),
            )
          ],
        ),
        _createContainer(Center(child: CustomText(text: setInfoMap["state"], size: 16, weight: FontWeight.w500)))
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomText(
          text: getDateToStringForYYYYMMDDHHMMKORInNow(),
          size: 10,
          color: const Color(0xff3C5FEB),
          weight: FontWeight.w500,
        ),
        CustomText(text: workInfo == null ? "" : (workInfo!.strAttendLeaveTime ?? ""), weight: FontWeight.w400, size: 10, color: Colors.black),
      ])
    ]);
  }

  Container _createContainer(Widget widget) {
    return Container(
        margin: const EdgeInsets.only(top: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xff3C5FEB), borderRadius: BorderRadius.circular(6)), child: widget);
  }

  Image _errorImage() {
    return Image.asset(
      "assets/workon_logo.png",
      fit: BoxFit.scaleDown,
      width: 48,
      height: 48,
    );
  }
}
