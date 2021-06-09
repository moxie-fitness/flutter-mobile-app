import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class AppBarSearchField extends StatelessWidget {
  @required final String hint;
  final TextInputType textInputType;
  @required final TextEditingController textEditingController;
  final FocusNode focusNode = new FocusNode();


  AppBarSearchField({
    this.hint,
    this.textInputType = TextInputType.text,
    this.textEditingController,
    });

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      controller: textEditingController,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: new InputDecoration(
        border: InputBorder.none,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 15.0),
        contentPadding: const EdgeInsets.only(
            top: 5.0, right: 5.0, bottom: 5.0, left: 5.0),
      ),
      keyboardType: textInputType,
      focusNode: focusNode,
    );
  }
}

