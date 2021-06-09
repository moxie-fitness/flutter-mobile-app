import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MoxieCheckBox extends CheckboxListTile {

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Widget title;
  final Widget subtitle;
  final Widget secondary;
  final bool isThreeLine;
  final bool dense;
  final bool selected;
  final ListTileControlAffinity controlAffinity;

  const MoxieCheckBox({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.activeColor = Colors.deepOrange,
    this.title,
    this.subtitle,
    this.isThreeLine: false,
    this.dense,
    this.secondary,
    this.selected: false,
    this.controlAffinity: ListTileControlAffinity.platform,
  }) : assert(value != null),
        assert(isThreeLine != null),
        assert(!isThreeLine || subtitle != null),
        assert(selected != null),
        assert(controlAffinity != null),
        super(
          key: key,
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
          title: title,
          subtitle: subtitle,
          isThreeLine: isThreeLine,
          dense: dense,
          secondary: secondary,
          selected: selected,
          controlAffinity: controlAffinity
        );
}