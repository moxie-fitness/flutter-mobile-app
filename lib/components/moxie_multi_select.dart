import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

typedef String MoxieDisplayBuilder<T>(T input);
typedef MoxieMultiSelectOption<T> MoxieMultiSelectOptionItemGenerator<T>(T input);

class ItemSelectUpdate<T>{
  T item;
  bool selected;
  ItemSelectUpdate(this.item, this.selected);
}


///
/// Example
///   new MoxieMultiSelect(
///        title: "Multi-Select test",
///        optionsPageTitle: 'asdfklj',
///        descriptionBuilder: (String item) {
///          return item;
///        },
///        options: _getOptions(),
///        preSelected: currentlySelected,
///        generator: (String item) {
///          return new MoxieMultiSelectOption<String>(
///            item: item,
///            display: item,
///            streamController: this.streamController,
///          );
///        },
///      ),
class MoxieMultiSelect<T> extends StatelessWidget {
  /// Creates a MultiSelect widget.
  ///
  /// The [onComplete] is the function callback that will contain the results as the only parameter,
  ///   if results are null, then it wasn't changed.
  ///
  ///  The [title] and [description] are just strings to display on the Widget, [description] is smaller text
  ///   displayed below title.
  ///
  ///  The [options] is an List<String> with a valid list of options the user can select,
  ///   and [preSelected] will contain all the already selected options. THESE TWO SHOULD NOT BE NULL.
  ///
  final String title;
  final String optionsPageTitle;
  final IconData leading = Icons.playlist_add;
  final IconData trailing = Icons.chevron_right;
  final List<T> options;
  final MoxieMultiSelectOptionItemGenerator<T> generator;
  final MoxieDisplayBuilder<T> descriptionBuilder;
  final Color color;
  final List<T> preSelected;

  MoxieMultiSelect({
    @required this.title,
    @required this.descriptionBuilder,
    this.optionsPageTitle,
    @required this.options,
    @required this.preSelected,
    @required this.generator,
    this.color = Colors.black
  })  : assert(options != null && options.length > 0, "options must not be null and contain at least 1 element"),
        assert(preSelected != null, "preSelected must not be null"),
        assert(title != null);

  @override
  Widget build(BuildContext context) {
    String desc = "";
    if(preSelected == null || preSelected.isEmpty) {
      desc += "None";
    } else {
      preSelected.forEach((p) {
        desc += '${descriptionBuilder(p)}, ';
      });
      desc = desc.substring(0, desc.length-2);
    }

    return new Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(
            width: 0.5,
            color: Colors.white24,
          ),
        ),
      ),
      child: new Column(
        children: <Widget>[
          new ListTile(
            leading: new Icon(
              Icons.playlist_add,
              color: this.color,
            ),
            trailing:  new Icon(
              Icons.chevron_right,
              color: this.color,
            ),
            title: new Text(
              '$title',
              style: new TextStyle(
                color: this.color
              )
            ),
            subtitle: new Text('$desc', style: new TextStyle(color: this.color)),
            onTap: () async {
              // Push new screen with options & wait for results
              Navigator.push(
                context,
                new MaterialPageRoute<T>(
                    builder: (context) =>
                    new _MoxieMultiSelectPage<T>(
                      options: options,
                      preSelected: preSelected,
                      optionsPageTitle: optionsPageTitle,
                      generator: this.generator,
                    )
                ),
              );
            },
          )
        ],
      )
    );
  }
}

class _MoxieMultiSelectPage<T> extends StatefulWidget {

  @required final List<T> options;
  final List<T> preSelected;
  final Widget optionsLeading;
  final Widget optionsTrailing;
  final String optionsPageTitle;
  final MoxieMultiSelectOptionItemGenerator<T> generator;

  _MoxieMultiSelectPage({
    this.options,
    this.preSelected,
    this.optionsPageTitle,
    this.optionsLeading,
    this.optionsTrailing,
    @required this.generator,
    }
  );

  @override
  _MoxieMultiSelectPageState createState() => new _MoxieMultiSelectPageState<T>(
  );
}

class _MoxieMultiSelectPageState<T> extends State<_MoxieMultiSelectPage<T>> {
  final Widget optionsLeading;
  final Widget optionsTrailing;
  List<MoxieMultiSelectOption<T>> widgetOptions;
  List<T> postSelected;

  _MoxieMultiSelectPageState(
    {
      this.optionsLeading,
      this.optionsTrailing,
    }
  );

  @override
  void initState() {
    postSelected = widget.preSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  new Scaffold(
      appBar: new AppBar(
        title: widget.optionsPageTitle == null ? new Text('Select Multiple') : new Text('${widget.optionsPageTitle}'),
        centerTitle: true,
      ),
      body: new Container(
        child: new ListView(
          children: _getWidgetListOptions(),
        ),
      ),
    );
  }

  List<MoxieMultiSelectOption<T>> _getWidgetListOptions() {
    widgetOptions = new List<MoxieMultiSelectOption<T>>();
    widget.options.forEach((item) {
      MoxieMultiSelectOption<T> mmso = widget.generator(item);
      mmso.defaultSelected = widget.preSelected.contains(item);
      widgetOptions.add(mmso);
    });
    return widgetOptions;
  }
}

class MoxieMultiSelectOption<T> extends StatefulWidget {
  @required final T item;
  final IconData leading;
  final IconData trailing;
  final Color color;
  final String display;
  final StreamController<ItemSelectUpdate<T>> streamController;
  bool defaultSelected;

  MoxieMultiSelectOption({
    @required this.item,
    @required this.display,
    this.leading,
    this.trailing = Icons.check,
    this.color = Colors.white,
    @required this.streamController
  });

  @override
  _MoxieMultiSelectOptionState<T> createState() => new _MoxieMultiSelectOptionState<T>(this.defaultSelected);
}

class _MoxieMultiSelectOptionState<T> extends State<MoxieMultiSelectOption<T>> {
  bool selected;
  Color color;

  _MoxieMultiSelectOptionState(
    [
      this.selected = false,
      this.color = Colors.white
    ]);

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: (selected ? Colors.deepOrange : color),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: new Icon(
              widget.leading,
              color: selected ? Colors.white : Colors.black,
            ),
            selected: selected,
            title: new Text("${widget.display}",
              style: new TextStyle(
                fontSize: 15.0,
                color: selected ? Colors.white : Colors.black
              ),
            ),
            trailing: (selected)
                ? new Icon(
                    widget.trailing,
                    color: selected ? Colors.white : Colors.black,
                  )
                : const Icon(Icons.radio_button_unchecked),
            onTap: select
          )
        ]
      ),
    );
  }

  void select() {
    setState(() {
      if (selected) {
        color = Colors.white;
        selected = false;

      } else {
        color = Colors.deepOrange;
        selected = true;
      }
      widget.streamController.add(new ItemSelectUpdate<T>(widget.item, selected));
    });
  }
}