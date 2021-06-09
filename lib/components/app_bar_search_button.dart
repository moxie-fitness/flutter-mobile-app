import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/utils/utils.dart';

class AppBarSearchButton extends StatelessWidget {
  @required final String hint;
  final TextInputType textInputType;
  final VoidCallback onTap;

  AppBarSearchButton({
    this.hint,
    this.textInputType = TextInputType.text,
    this.onTap,
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
              Icons.search,
              color: Colors.white,
            ),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white, fontSize: 15.0),
            contentPadding: const EdgeInsets.only(
                top: 5.0, right: 3.0, bottom: 5.0, left: 3.0),
          ),
          child: CustomText.qarmicSans(
            text:  this.hint,
            fontSize: 16.0,
          ),
        ),
        param: this.onTap
      ),
    );
  }
}

