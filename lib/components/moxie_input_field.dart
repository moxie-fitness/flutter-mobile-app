import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

class MoxieInputFieldArea extends StatelessWidget {
  @required
  final String hint;
  final bool obscure;
  final IconData icon;
  final TextInputType textInputType;
  @required
  final TextEditingController textEditingController;
  final FormFieldValidator<String> validator;
  final int maxLines;
  final int maxLength;
  final TextStyle style;
  final TextStyle hintStyle;
  final Color iconColor;
  final Color decorationColor;
  final num height;
  final FocusNode focusNode = FocusNode();

  MoxieInputFieldArea({
    this.hint,
    this.obscure = false,
    this.icon,
    this.textInputType = TextInputType.text,
    this.textEditingController,
    this.validator,
    this.maxLines = 1,
    this.maxLength = 100,
    this.height = 100.0,
    this.style = const TextStyle(
      color: Colors.white,
    ),
    this.hintStyle = const TextStyle(color: Colors.white70, fontSize: 15.0),
    this.iconColor = Colors.white,
    this.decorationColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (textInputType != null && textInputType == TextInputType.multiline) {
      return _buildMultiline();
    } else {
      final iconInputDecoration = icon == null
          ? InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: this.hintStyle,
              contentPadding: const EdgeInsets.only(
                  top: 8.0, right: 8.0, bottom: 8.0, left: 8.0),
            )
          : InputDecoration(
              icon: Icon(
                icon,
                color: this.iconColor,
              ),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: this.hintStyle,
              contentPadding: const EdgeInsets.only(
                  top: 8.0, right: 8.0, bottom: 8.0, left: 8.0),
            );

      return (Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.15,
                color: decorationColor,
              ),
            ),
          ),
          child: TextFormField(
            obscureText: obscure,
            controller: textEditingController,
            validator: validator,
            style: this.style,
            decoration: iconInputDecoration,
            keyboardType: textInputType,
          )));
    }
  }

  _buildMultiline() {
    return (Container(
        height: height,
        child: Theme(
          data: ThemeData(
            hintColor: this.hintStyle.color,
          ),
          child: TextFormField(
            obscureText: obscure,
            controller: textEditingController,
            validator: validator,
            style: this.style,
            maxLines: this.maxLength,
            maxLength: this.maxLength,
            decoration: InputDecoration(
              icon: Icon(
                icon,
                color: this.iconColor,
              ),
              border: OutlineInputBorder(),
              hintText: hint,
              helperStyle: this.hintStyle,
              hintStyle: this.hintStyle,
              contentPadding: const EdgeInsets.only(
                  top: 8.0, right: 8.0, bottom: 8.0, left: 8.0),
            ),
            keyboardType: textInputType,
            // focusNode: focusNode
          ),
        )));
  }
}
