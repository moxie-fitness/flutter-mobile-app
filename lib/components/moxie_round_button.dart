import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MoxieRoundButton extends StatelessWidget {

  final String data;
  final VoidCallback onTap;
  final double height;
  final double width;
  final Image image;
  final Color color;
  final Color textColor;

  MoxieRoundButton({
    @required this.data,
    @required this.onTap,
    this.height,
    this.width,
    this.image,
    this.color = Colors.orange,
    this.textColor = Colors.white
  });

  Widget _buildText() {
    return new Text(
      data,
      style: new TextStyle(
        color: textColor,
        fontSize: 20.0,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.3
      ),
    );
  }

  Widget _buildContent() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        image,
        _buildText()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onTap,
      child: new Container(
        width: width,
        height: height,
        alignment: FractionalOffset.center,
        decoration: new BoxDecoration(
          color: color,
          borderRadius: new BorderRadius.all(const Radius.circular(30.0)),
        ),
        child: image == null ? _buildText():_buildContent(),
      ),
    );
  }
}