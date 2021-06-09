import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/pages/core/moxie_list_page.dart';
import 'package:redux/redux.dart';

class RoutinesListPage extends StatefulWidget {

  @override
  RoutinesListPageState createState () => new RoutinesListPageState();
}

class RoutinesListPageState extends State<RoutinesListPage> implements FilterAndSortList<Routine> {
  RoutineListFilter _filter = new RoutineListFilter();
  StreamController<RoutineListFilter> filterUpdateController;

  @override
  void initState() {
    super.initState();
    filterUpdateController = new StreamController<RoutineListFilter>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MoxieListPage<Routine, RoutineListFilter>(
      appBarTitle: 'Routines',
      fab: new FloatingActionButton(
        onPressed: () => Routes.router.navigateTo(context, Routes.routinesCreate),
        child: new Icon(Icons.add),
      ),
      onScrolledToBottom: () {
        final storeProvider = StoreProvider.of<MoxieAppState>(context);
        storeProvider.dispatch(new LoadRoutinesAction(
          filter: _filter
            ..take = 15
            ..offset = storeProvider.state.routines.length,
        ));
      },
      onRefreshAction: new LoadRoutinesAction(
        filter: _filter
          ..take = 15
          ..offset = 0,
        freshValues: true
      ),
      bottomSheetFilter: bottomSheetFilter(),
      viewModelConverter: (store) => RoutinesListViewModel.from(store),
      listItemGenerate: (routine) {
        return generateListItem(routine);
      },
      filterUpdateController: getFilterController()
    );
  }

  @override
  Widget bottomSheetFilter() {
    return new StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return new Container(
          color: Theme.of(context).accentColor.withOpacity(0.8),
          height: 300.0,
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: new CustomText.qarmicSans(
                  text: 'Sort By',
                  fontSize: 18.0,
                ),
              ),
              new MoxieDropdown<RoutinesSort>(
                leadingIcon: Icons.sort,
                options: RoutinesSort.values,
                preSelected: _filter.sortBy,
                onChanged: (RoutinesSort item) {
                  print('SELECTED: $item');
                  setState(() {
                    _filter.sortBy = item;
                  });
                },
                menuItemsGenerator: (RoutinesSort option) {
                  String display; // default
                  switch (option) {
                    case RoutinesSort.name:
                      display = 'By name (a-z)';
                      break;
                    case RoutinesSort.workout_count:
                      display = 'By workouts count';
                      break;
                    default:
                      display = 'Error';
                      break;
                  }
                  return new DropdownMenuItem<RoutinesSort>(
                    child: new Text('$display'),
                    value: option,
                  );
                },
              ),
              new Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: new CustomText.qarmicSans(
                  text: 'Filter',
                  fontSize: 18.0,
                ),
              ),
              new MoxieSwitchInput(
                value: _filter.showMineOnly,
                title: new InputDecorator(
                  decoration: new InputDecoration(
                    icon: new Icon(
                      Icons.merge_type,
                      color: Colors.white,
                    ),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: Colors.white, fontSize: 15.0),
                    contentPadding: const EdgeInsets.only(
                        top: 5.0, right: 5.0, bottom: 5.0, left: 5.0),
                  ),
                  child: new Text(
                    _filter.showMineOnly ? 'Show only mine!' : 'Show Moxie\'s also!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0
                    ),
                  ),
                ),
                onChanged: (gender) {
                  setState(() {
                    _filter.showMineOnly = gender == null ? false : gender;
                    print(_filter.showMineOnly);
                  });
                }
              ),
              new MoxieFlatButton(
                data: 'Ok',
                onPressed: () {
                  filterUpdateController.add(_filter);
                }
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget generateListItem(Routine item) {
    return new RoutineListItem(
      routine: item,
      outerBgColor: Theme.of(context).primaryColor,
    );
  }

  getFilterController() {
    if(filterUpdateController == null) {
      filterUpdateController = new StreamController<RoutineListFilter>();
    }
    return filterUpdateController;
  }
}


class RoutinesListViewModel implements ViewModel<Routine>{
  final List<Routine> routines;
  final bool loading;
  final bool allLoaded;

  RoutinesListViewModel({
    this.routines,
    this.loading,
    this.allLoaded,
  });

  static RoutinesListViewModel from(Store<MoxieAppState> store) {
    return new RoutinesListViewModel(
      routines: store.state.routines?.values?.toList() ?? <Routine>[],
      loading: store.state.viewLoadersState.routinesListLoading,
      allLoaded: store.state.allRoutinesLoaded
    );
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is RoutinesListViewModel &&
        runtimeType == other.runtimeType &&
        routines == other.routines &&
        allLoaded == other.allLoaded &&
        loading == other.loading;

  @override
  int get hashCode => routines.hashCode ^
    loading.hashCode ^
    allLoaded.hashCode;

  @override
  List<Routine> get items => routines;
}

class RoutineListFilter extends FilterAndSortable {
  bool showMineOnly;
  Order order;

  RoutineListFilter({
    this.order,
    take = 15,
    offset = 0,
    sortBy = RoutinesSort.name,
    this.showMineOnly = true} // Includes Moxie Fitness by default.
  ) : super(take, offset, sortBy);

  @override
  Map getFilterMap() {
    Map map = super.getFilterMap();
    map['onlyMine'] = showMineOnly?.toString();

    if(order != null) {
      map['order'] = order?.toString();
    }
    return map;
  }
}

