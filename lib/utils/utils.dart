import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
//import 'package:validator/validator.dart';

class Utils {
  static void showBasicSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(text),
    ));
  }

  static void showBasicErrorSnackBar(BuildContext context,
      [String error = "Unexpected error, try again later."]) {
    showBasicSnackBar(context, error);
  }

  static addClick({Widget widget, Function param}) {
    return new GestureDetector(child: widget, onTap: param);
  }

  static forceCloseKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static getBackArrowIcon(Function param) {
    return new GestureDetector(
        child: new Icon(
          Icons.arrow_back,
          color: Colors.white24,
        ),
        onTap: param);
  }

  static String simpleTextValidator(String val,
      {who = 'Text', minLength = 10, maxLength = 100}) {
    if (val == null) {
      return "$who can't be empty!";
    }

    if (val.length < minLength) {
      return "$who must be at least $minLength characters!";
    }

    if (val.length > maxLength) {
      return "$who can only be up to $maxLength characters!";
    }
    return null;
  }

  static String simpleNumberValidator(String val,
      {who = 'Text', minVal = 1, maxVal = 1000, bool canBeEmpty}) {
    if (canBeEmpty && (val == null || val.isEmpty)) {
      return null;
    }

    if (val == null || val.length == 0) {
      return "$who can't be empty!";
    }

    num number = int.parse(val);
    if (number == null || !isNumeric(val)) {
      return "$who is not valid!";
    }

    if (number < minVal) {
      return "$who must be at least $minVal!";
    }

    if (number > maxVal) {
      return "$who can only be up to $maxVal!";
    }
    return null;
  }

  static String emailValidator(String val) {
    if (val == null) {
      return "Email can't be empty!";
    }

    if (!isEmail(val)) {
      return "Email is not valid!";
    }

    return null;
  }

  static String passwordValidator(String val) {
    if (val == null) {
      return "Password can't be empty!";
    }

    if (!isLength(val, 6)) {
      return "Password has to be a minimum of 6 characters";
    }

    return null;
  }

  static usernameValidator(String val) {
    final minLength = 8;
    final maxLength = 55;

    if (val == null) {
      return "Username can't be empty!";
    }

    if (val.length < minLength) {
      return "Username must be at least $minLength characters!";
    }

    if (val.length > maxLength) {
      return "Username must be les than $maxLength characters!";
    }

    if (val.contains(new RegExp(r"[\' \[ \] $ # % ^ & * ( )] < > ,"))) {
      return "Username must not contain characters such as: \" \' \\ ";
    }

    if (val.contains(' ')) {
      return "Username must not contain spaces!";
    }

    return null;
  }

  static List<Color> getTenRandomColors() {
    List<Color> colors = new List<Color>()
      ..add(Colors.blue)
      ..add(Colors.orange)
      ..add(Colors.deepOrange)
      ..add(Colors.red)
      ..add(Colors.pink)
      ..add(Colors.yellow)
      ..add(Colors.green)
      ..add(Colors.teal)
      ..add(Colors.tealAccent)
      ..add(Colors.purple);
    colors.shuffle();
    return colors;
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static Future<List<String>> UploadImages(
      {StorageReference reference, List<File> files}) async {
    final List<String> media = <String>[];
    for (var i = 0; i < files.length; i++) {
      final current =
          reference.child('${new DateTime.now().millisecondsSinceEpoch}.png');
      final StorageUploadTask uploadTask = current.putFile(files[i]);
      media.add((await (await uploadTask.onComplete).ref.getDownloadURL()));
    }
    return media;
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static bool isLength(String s, num length) {
    return s.length >= length;
  }

  static bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  static String convertDateToDisplay(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String convertDateToDisplayWithTime(DateTime date) {
    return DateFormat.MMMd().add_jm().format(date);
  }

  static String convertDateToDisplayOnlyTime(DateTime date) {
    return DateFormat.jm().format(date);
  }
}
