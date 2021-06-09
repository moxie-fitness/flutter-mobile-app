import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MoxieSwitchInput extends SwitchListTile {

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final ImageProvider activeThumbImage;
  final ImageProvider inactiveThumbImage;
  final Widget title;
  final Widget subtitle;
  final Widget secondary;
  final bool isThreeLine;
  final bool dense;
  final bool selected;

  const MoxieSwitchInput({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.activeColor,
    this.activeThumbImage,
    this.inactiveThumbImage,
    this.title,
    this.subtitle,
    this.isThreeLine: false,
    this.dense,
    this.secondary,
    this.selected: false,
  }) : assert(value != null),
      assert(isThreeLine != null),
      assert(!isThreeLine || subtitle != null),
      assert(selected != null),
      super(
        key: key,
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeThumbImage: activeThumbImage,
        inactiveThumbImage: inactiveThumbImage,
        title: title,
        subtitle: subtitle,
        isThreeLine: isThreeLine,
        dense: dense,
        secondary: secondary,
        selected: selected,
    );
}