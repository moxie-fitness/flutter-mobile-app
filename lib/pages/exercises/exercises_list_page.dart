import 'dart:async';
import 'dart:convert';

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

class ExercisesListPage extends StatefulWidget {
  // When [exercisesAddController] is null, then the add icon is not shown.
  // Set a non-null list to add items to it, will be returned when popped.
  final StreamController<CreateWorkoutExerciseUpdate>
      createWorkoutExercisesAddController;

  // When [exercisesAddController] is not null, [maxExercises] is compared against
  // [currentExercises] before sending add update to stream.
  final num createWorkoutMaxExercises;
  final num createWorkoutCurrentExercises;

  ExercisesListPage(
      {this.createWorkoutExercisesAddController,
      this.createWorkoutMaxExercises,
      this.createWorkoutCurrentExercises});

  @override
  _ExercisesListPageState createState() => _ExercisesListPageState();
}

class _ExercisesListPageState extends State<ExercisesListPage>
    implements FilterAndSortList<Exercise> {
  ExerciseListFilter _filter = ExerciseListFilter(<int>[]);
  StreamController<ExerciseListFilter> filterUpdateController;

  _ExercisesListPageState() {
    filterUpdateController = StreamController<ExerciseListFilter>();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    filterUpdateController.close();
  }

  @override
  Widget build(BuildContext context) {
    return MoxieListPage<Exercise, ExerciseListFilter>(
        appBarTitle: 'Exercises',
        fab: widget.createWorkoutExercisesAddController == null
            ? FloatingActionButton(
                onPressed: () =>
                    Routes.router.navigateTo(context, Routes.exercisesCreate),
                child: Icon(Icons.add),
              )
            : null,
        onScrolledToBottom: () {
          final storeProvider = StoreProvider.of<MoxieAppState>(context);
          if (!storeProvider.state.allExercisesLoaded &&
              !storeProvider.state.viewLoadersState.exercisesListLoading) {
            storeProvider.dispatch(LoadExercisesAction(
              filter: _filter
                ..take = 15
                ..offset = storeProvider.state.exercises.length,
            ));
          }
        },
        onRefreshAction: LoadExercisesAction(
            filter: _filter
              ..take = 15
              ..offset = 0,
            freshValues: true),
        bottomSheetFilter: bottomSheetFilter(),
        viewModelConverter: (store) => _ViewModel.from(store),
        listItemGenerate: (exercise) {
          return generateListItem(exercise);
        },
        filterUpdateController: getFilterController());
  }

  StreamController<ExerciseListFilter> getFilterController() {
    if (filterUpdateController == null) {
      filterUpdateController = StreamController<ExerciseListFilter>();
    }
    return filterUpdateController;
  }

  @override
  Widget bottomSheetFilter() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        color: Theme.of(context).accentColor.withOpacity(0.8),
        height: 300.0,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomText.qarmicSans(
                text: 'Sort By',
                fontSize: 18.0,
              ),
            ),
            MoxieDropdown<ExercisesSort>(
              leadingIcon: Icons.sort,
              options: ExercisesSort.values,
              preSelected: _filter.sortBy,
              onChanged: (ExercisesSort item) {
                print('SELECTED: $item');
                setState(() {
                  _filter.sortBy = item;
                });
                _refreshWithUpdatedFilter();
              },
              menuItemsGenerator: (ExercisesSort option) {
                String display; // default
                switch (option) {
                  case ExercisesSort.name:
                    display = 'By name (a-z)';
                    break;
                  case ExercisesSort.nameReverse:
                    display = 'By name reverse (z-a)';
                    break;
                  default:
                    display = 'Error';
                    break;
                }
                return DropdownMenuItem<ExercisesSort>(
                  child: Text('$display'),
                  value: option,
                );
              },
            ),
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              child: CustomText.qarmicSans(
                text: 'Filter',
                fontSize: 18.0,
              ),
            ),
            MoxieSwitchInput(
                value: _filter.showMineOnly,
                title: InputDecorator(
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.merge_type,
                      color: Colors.white,
                    ),
                    border: InputBorder.none,
                    hintStyle:
                        const TextStyle(color: Colors.white, fontSize: 15.0),
                    contentPadding: const EdgeInsets.only(
                        top: 5.0, right: 5.0, bottom: 5.0, left: 5.0),
                  ),
                  child: Text(
                    _filter.showMineOnly
                        ? 'Show only mine!'
                        : 'Show mine & Moxie\'s also!',
                    style: const TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _filter.showMineOnly = value;
                    print(_filter.showMineOnly);
                  });
                  _refreshWithUpdatedFilter();
                }),
            MoxieFlatButton(
                data: 'Ok',
                onPressed: () {
                  filterUpdateController.add(_filter);
                })
          ],
        ),
      );
    });
  }

  void _refreshWithUpdatedFilter() {
    final storeProvider = StoreProvider.of<MoxieAppState>(context);
    storeProvider.dispatch(LoadExercisesAction(
        filter: _filter
          ..take = 15
          ..offset = 0));
  }

  @override
  Widget generateListItem(item) {
    return ExerciseListItem(
      exercise: item,
      exercisesAddController: widget.createWorkoutExercisesAddController,
      autoplay: false,
      maxExercises: widget.createWorkoutMaxExercises,
      currentExercises: widget.createWorkoutCurrentExercises,
    );
  }
}

class _ViewModel implements ViewModel<Exercise> {
  final List<Exercise> exercises;
  final List<LookupOption> muscles;
  final bool loading;
  final bool allLoaded;

  _ViewModel({this.exercises, this.muscles, this.loading, this.allLoaded});

  static _ViewModel from(Store<MoxieAppState> store) {
    return _ViewModel(
        exercises: store.state.exercises?.values?.toList() ?? <Exercise>[],
        muscles: <LookupOption>[],
        loading: store.state.viewLoadersState.exercisesListLoading,
        allLoaded: store.state.allExercisesLoaded);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          muscles == other.muscles &&
          exercises == other.exercises;

  @override
  int get hashCode => exercises.hashCode;

  @override
  List<Exercise> get items => exercises;
}

class ExerciseListFilter extends FilterAndSortable {
  bool showMineOnly;
  List<int> musclesLookupOptionIdsFilter;

  ExerciseListFilter(this.musclesLookupOptionIdsFilter,
      [this.showMineOnly = false, sortBy = ExercisesSort.name, take, offset])
      : super(take, offset, sortBy) {
    if (musclesLookupOptionIdsFilter == null) {
      musclesLookupOptionIdsFilter = <int>[];
    }
  }

  @override
  Map getFilterMap() {
    var map = super.getFilterMap();
    map['onlyMine'] = showMineOnly.toString();
    map['musclesFilter'] = '${json.encode(musclesLookupOptionIdsFilter)}';
    return map;
  }
}
