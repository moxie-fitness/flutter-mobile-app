import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MoxieFlatButton extends StatelessWidget {

  final String data;
  final VoidCallback onPressed;
  final Color textColor;
  final double fontSize;
  final fontWeight;

  MoxieFlatButton({
    @required this.data,
    @required this.onPressed,
    this.textColor = Colors.white,
    this.fontSize = 12.0,
    this.fontWeight = FontWeight.w300
  });

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
        onPressed: this.onPressed,
        child: new Text(
          data,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          style: new TextStyle(
            fontWeight: this.fontWeight,
            letterSpacing: 0.5,
            color: this.textColor,
            fontSize: fontSize,
          ),
        )
    );
  }


}