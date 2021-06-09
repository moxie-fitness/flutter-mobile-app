import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:moxie_fitness/components/components.dart';
import 'package:moxie_fitness/config/routes.dart';
import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/utils/filterable.dart';
import 'package:moxie_fitness/pages/core/moxie_list_page.dart';
import 'package:redux/redux.dart';

class WorkoutsListPage extends StatefulWidget {
  // When [exercisesAddController] is null, then the add icon is not shown.
  // Set a non-null list to add items to it, will be returned when popped.
  final StreamController<CreateRoutineWorkoutUpdate> createRoutineWorkoutsAddController;

  // The [workoutsInWeeklyOrder] map contains all of the currently added workouts
  // when adding from the routine.
  final Map<int, List<Workout>> workoutsInWeeklyOrder;

  // When [exercisesAddController] is not null, [maxExercises] is compared against
  // [currentExercises] before sending add update to stream.
  final num createRoutineMaxWeeks;

  WorkoutsListPage({
    this.createRoutineWorkoutsAddController,
    this.workoutsInWeeklyOrder,
    this.createRoutineMaxWeeks = 12
  });

  WorkoutsListPage.picker({
    @required this.createRoutineWorkoutsAddController,
    @required this.workoutsInWeeklyOrder,
    this.createRoutineMaxWeeks = 12
  }) : assert(createRoutineWorkoutsAddController != null),
        assert(workoutsInWeeklyOrder != null),
        assert(createRoutineMaxWeeks != null);


  @override
  WorkoutsListPageState createState () => new WorkoutsListPageState();
}

class WorkoutsListPageState extends State<WorkoutsListPage> implements FilterAndSortList<Workout>{
  WorkoutListFilter _filter = new WorkoutListFilter();
  StreamController<WorkoutListFilter> filterUpdateController;

  WorkoutsListPageState(){
    filterUpdateController = new StreamController<WorkoutListFilter>();
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
    filterUpdateController.close();
  }

  @override
  Widget build(BuildContext context) {
    return new MoxieListPage<Workout, WorkoutListFilter>(
        appBarTitle: 'Workouts',
        fab: widget.createRoutineWorkoutsAddController == null
            ? new FloatingActionButton(
          onPressed: () => Routes.router.navigateTo(context, Routes.workoutsCreate),
          child: new Icon(Icons.add),
        ) : null,
        onScrolledToBottom: () {
          final storeProvider = StoreProvider.of<MoxieAppState>(context);
          if(!storeProvider.state.allWorkoutsLoaded && !storeProvider.state.viewLoadersState.workoutsListLoading) {
            storeProvider.dispatch(new LoadWorkoutsAction(
              filter: _filter
                ..take = 15
                ..offset = storeProvider.state.workouts.length,
            ));
          }
        },
        onRefreshAction: new LoadWorkoutsAction(
            filter: _filter
              ..take = 15
              ..offset = 0,
            freshValues: true
        ),
        bottomSheetFilter: bottomSheetFilter(),
        viewModelConverter: (store) => _ViewModel.from(store),
        listItemGenerate: (workout) {
          return generateListItem(workout);
        },
        filterUpdateController: getFilterController()
    );
  }

  @override
  Widget bottomSheetFilter() {
    return new StatefulBuilder(
      builder: (BuildContext context, setState) {
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
              new MoxieDropdown<WorkoutsSort>(
                leadingIcon: Icons.sort,
                options: WorkoutsSort.values,
                preSelected: _filter.sortBy,
                onChanged: (WorkoutsSort item) {
                  print('SELECTED: $item');
                  setState(() {
                    _filter.sortBy = item;
                  });
                },
                menuItemsGenerator: (WorkoutsSort option) {
                  String display; // default
                  switch (option) {
                    case WorkoutsSort.name:
                      display = 'By name';
                      break;
                    case WorkoutsSort.exercise_count:
                      display = 'By exercise count';
                      break;
                    default:
                      display = 'Error';
                      break;
                  }
                  return new DropdownMenuItem<WorkoutsSort>(
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
      },
    );
  }

  @override
  Widget generateListItem(Workout item) {
    return widget.createRoutineWorkoutsAddController == null
        ? new WorkoutListItem(
      workout: item,
    ) : new WorkoutListItem.withAdd(
        workout: item,
        createRoutineWorkoutsAddController: widget.createRoutineWorkoutsAddController,
        workoutsInWeeklyOrder: widget.workoutsInWeeklyOrder,
        createRoutineMaxWeeks: widget.createRoutineMaxWeeks);
  }

  getFilterController() {
    if(filterUpdateController == null) {
      filterUpdateController = new StreamController<WorkoutListFilter>();
    }
    return filterUpdateController;
  }
}

class _ViewModel implements ViewModel<Workout>{
  final List<Workout> workouts;
  final bool loading;
  final bool allLoaded;

  _ViewModel({
    this.workouts,
    this.loading,
    this.allLoaded,
  });

  static _ViewModel from(Store<MoxieAppState> store) {
    
    return new _ViewModel(
        workouts: store.state.workouts?.values?.toList() ?? <Workout>[],
        loading: store.state.isLoading,
        allLoaded: store.state.allWorkoutsLoaded
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _ViewModel &&
              runtimeType == other.runtimeType &&
              workouts == other.workouts &&
              allLoaded == other.allLoaded &&
              loading == other.loading;

  @override
  int get hashCode => workouts.hashCode ^
  loading.hashCode ^
  allLoaded.hashCode;

  @override
  List<Workout> get items => workouts;
}

class WorkoutListFilter extends FilterAndSortable {
  bool showMineOnly;
  Order order;

  WorkoutListFilter({
    this.order,
    take = 15,
    offset = 0,
    sortBy = WorkoutsSort.name,
    this.showMineOnly = false}
      ) : super(take, offset, sortBy);

  @override
  Map getFilterMap() {
    Map map = super.getFilterMap();

    map['onlyMine'] = showMineOnly.toString();

    if(order != null) {
      map['order'] = order.toString();
    }
    return map;
  }
}

