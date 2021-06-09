import 'package:flutter/material.dart';

class Oops extends StatelessWidget {

  final errorMessage;

  Oops(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Padding(padding: new EdgeInsets.all(40.0),
          child: new Padding(padding: new EdgeInsets.all(40.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Padding(padding: new EdgeInsets.only(bottom: 40.0),
                  child: new Text('🐣',
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      fontSize: 55.0,
                    ),
                  ),
                ),
                new Text('Oops!',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    color: theme.primaryColor,
                    fontSize: 32.0,
                    decorationStyle: TextDecorationStyle.wavy
                  ),
                ),
                new Padding(padding: new EdgeInsets.only(top: 20.0),
                  child: new Text(errorMessage,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        color: theme.primaryColor,
                        fontSize: 22.0,
                        decorationStyle: TextDecorationStyle.wavy
                    ),
                  ),
                ),
              ],
            ),
          )
        )
      ],
    );
  }
}
