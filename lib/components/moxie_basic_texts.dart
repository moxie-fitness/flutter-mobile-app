import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {

  final text;
  final color;
  final maxLines;
  final overflow;
  final family;
  final double fontSize;
  final FontWeight fontWeight;

  CustomText.flamanteRoma({
    this.text,
    this.color = Colors.white,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal
  }) : family = 'FlamanteRoma';

  CustomText.qarmicSans({
    this.text,
    this.color = Colors.white,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.normal
  }) : family = 'QarmicSans';

  @override
  Widget build(BuildContext context) {
    return new Text(
      '${text ?? ''}',
      overflow: overflow,
      maxLines: maxLines,
      style: new TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'QarmicSans',
        fontWeight: fontWeight,
      ),
    );
  }
}
