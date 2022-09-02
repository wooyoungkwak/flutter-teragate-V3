import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final String? family;
  final Color color;
  final double? height;
  final EdgeInsetsGeometry padding;
  final bool? isOverlfow;

  const CustomText({
    Key? key,
    this.text = "text를 확인해주세요",
    this.size = 18.0,
    this.weight = FontWeight.bold,
    this.family = "SpoqaHanSansNeo",
    this.color = Colors.white,
    this.height,
    this.padding = const EdgeInsets.all(0.0),
    this.isOverlfow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          height: height,
          fontSize: size,
          fontWeight: weight,
          color: color,
          fontFamily: family,
          overflow: isOverlfow! ? TextOverflow.ellipsis : TextOverflow.visible,
        ),
      ),
    );
  }
}
