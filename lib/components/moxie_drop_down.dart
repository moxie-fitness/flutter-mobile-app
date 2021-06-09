import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

///
/// This typdef is used to show the MoxieDropdown how to create
/// each [DropdownMenuItem] from the given T [input] for each
/// item in List<T> [options]
///
/// Pass it in to [menuItemsGenerator] in [MoxieDropdown] constructor.
typedef DropdownMenuItem<T> MoxieDropdownItemGenerator<T>(T input);

///
/// Example
///       new MoxieDropdown<LookupOption>(
///          options: opts,
///          preSelected: this.selected,
///          onChanged: (LookupOption item) {
///            print("SELECTED: ${item.value} with ID: ${item.id}");
///
///            setState(() {
///              this.selected = item;
///            });
///          },
///          menuItemsGenerator: (LookupOption option) {
///            return new DropdownMenuItem<LookupOption>(
///              child: new Text('${option.value}'),
///              value: option,
///            );
///          },
///        ),

class MoxieDropdown<T> extends StatelessWidget {

  final List<T> options;
  final T preSelected;
  final ValueChanged<T> onChanged;
  final IconData leadingIcon;
  final Color color;
  final MoxieDropdownItemGenerator<T> menuItemsGenerator;

  MoxieDropdown({
    this.options,
    this.preSelected,
    @required this.onChanged,
    this.leadingIcon = Icons.fitness_center,
    this.color = Colors.white,
    this.menuItemsGenerator
  });


  @override
  Widget build(BuildContext context) {

    final dropdownItems = _generateDropdownItems();

    return new ListTile(
      leading: new Icon(
        this.leadingIcon,
        color: this.color,
      ),
      title: new Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).primaryColor
        ),
        child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<T>(
                items: dropdownItems,
                onChanged: this.onChanged,
                value: this.preSelected ?? this.options[0],
                style: new TextStyle(
                  color: this.color,
                ),
              ),
            )
        ),
      ),
    );
  }

  List<DropdownMenuItem<T>> _generateDropdownItems() {
    List<DropdownMenuItem<T>> menuItems = <DropdownMenuItem<T>>[];
    this.options.forEach((option) {
      menuItems.add(this.menuItemsGenerator(option));
    });
    return menuItems;
  }
}
