import 'package:flutter/material.dart';

class CenteredCircularProgress extends StatelessWidget {

  final Color backgroundColor;

  CenteredCircularProgress({
    this.backgroundColor = Colors.transparent
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: this.backgroundColor,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Center(
            child: new CircularProgressIndicator(
              backgroundColor: Colors.transparent,
            )
          )
        ],
      ),
    );
  }
}
