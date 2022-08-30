import 'package:flutter/material.dart';
import 'package:teragate_v3/state/widgets/custom_text.dart';

class CustomBusinessCard extends StatelessWidget {
  final String? company;
  final String? name;
  final String? position;
  final bool? workbool;
  final String? worktime;

  const CustomBusinessCard(
      {Key? key,
      this.company,
      this.name,
      this.position,
      this.workbool,
      this.worktime})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String profilePicture =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7X1a5uXND5eV1xt1ihm1RqafYqZ2_iFAWeg&usqp=CAU';

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                profilePicture,
                fit: BoxFit.cover,
                width: 48,
                height: 48,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                        text: company!,
                        weight: FontWeight.w500,
                        size: 14,
                        color: Colors.black),
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
            ? _createContainer(const Center(
                child:
                    CustomText(text: "업무중", size: 16, weight: FontWeight.w500)))
            : _createContainer(
                const Center(
                    child: CustomText(
                        text: "업무종료", size: 16, weight: FontWeight.w500)),
              )
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomText(
          text: DateTime.now().toString(),
          size: 14,
          color: const Color(0xff3C5FEB),
          weight: FontWeight.w500,
        ),
        CustomText(
            text: worktime!,
            weight: FontWeight.w400,
            size: 14,
            color: Colors.black),
      ])
    ]);
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
}
