import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NoResultsFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            height: 100,
            child: Card(
              elevation: 12,
              child: Center(
                  child: Container(
                      child: Text(
                'Oops. Nothing to see here.',
                style: Theme.of(context).textTheme.display1,
              ))),
            ),
          ),
        ),
      ],
    );
  }
}
