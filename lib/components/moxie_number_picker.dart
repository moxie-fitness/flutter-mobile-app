import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moxie_fitness/utils/utils.dart';
import 'package:numberpicker/numberpicker.dart';

class MoxieNumberPicker extends StatelessWidget {

  @required final String hint;
  @required final String title;
//  final TextInputType type;
  final Function onUpdated;
  final num current;
  final num min;
  final num max;
  @required final int decimalPlaces;
  final IconData icon;

  MoxieNumberPicker({
    this.title,
    this.hint,
    this.onUpdated,
    this.current,
    this.max,
    this.min,
    this.decimalPlaces = 0,
//    this.type,
    this.icon
  });


  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            width: 0.5,
            color: Colors.white24,
          ),
        ),
      ),
      child: Utils.addClick(
        widget: new InputDecorator(
          decoration: new InputDecoration(
            icon: new Icon(
              icon,
              color: Colors.white,
            ),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white, fontSize: 15.0),
            contentPadding: const EdgeInsets.only(
                top: 5.0, right: 5.0, bottom: 5.0, left: 5.0),
          ),
          child: new Text(
            this.hint,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0
            ),
          ),
        ),
        param: () async {
          num updated;
          if(decimalPlaces > 0) {
            updated = await _showDialog(
              context,
              new NumberPickerDialog.decimal(
                minValue: min,
                maxValue: max,
                initialDoubleValue: current,
                decimalPlaces: decimalPlaces,
                title: new Text('$title'),
            )
            );
          } else {
            updated = await _showDialog(
              context,
              new NumberPickerDialog.integer(
                minValue: min,
                maxValue: max,
                initialIntegerValue: current,
                title: new Text('$title'),
              )
            );
          }

          // Execute callback with new value.
          onUpdated(updated);
        }
      ),
    );
  }

  Future<num> _showDialog(context, dialog) async {
    return await showDialog<num>(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        }
    );
  }
}
