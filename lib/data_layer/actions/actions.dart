import 'dart:async';
import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/utils/filterable.dart';

class BaseLoadAction {
  num retries;
  BaseLoadAction({
    this.retries = 3
  });
}

//Moxieusers
class LoadMoxieuserAction {}
class MoxieuserLoadedAction extends BaseLoadAction {
  final Moxieuser moxieuser;
  MoxieuserLoadedAction({this.moxieuser});
}

class SaveMoxieuserDetailsAction {
  final Moxieuser moxieuser;
  final OnItemSavedCallback<Null> onSavedCallback;
  SaveMoxieuserDetailsAction({
    this.moxieuser,
    this.onSavedCallback});
}

//Exercises
class LoadExercisesAction {
  Completer completer;
  final FilterAndSortable filter;
  final bool freshValues;
  LoadExercisesAction({
    this.filter,
    this.completer,
    this.freshValues = false
  });
}
class ExercisesLoadedAction {
  final LinkedHashMap<num, Exercise> exercises;
  final FilterAndSortable filter;
  final bool freshValues;
  ExercisesLoadedAction({
    this.freshValues = false,
    this.filter,
    this.exercises
  });
}

//Workouts
class LoadWorkoutsAction {
  Completer completer;
  final FilterAndSortable filter;
  final bool freshValues;
  LoadWorkoutsAction({
    this.filter,
    this.completer,
    this.freshValues = false
  });
}
class WorkoutsLoadedAction {
  final LinkedHashMap<num, Workout> workouts;
  final FilterAndSortable filter;
  final bool freshValues;
  WorkoutsLoadedAction({
    this.filter,
    this.freshValues = false,
    this.workouts
  });
}

//Routines
class LoadRoutinesAction {
  Completer completer;
  final FilterAndSortable filter;
  final bool freshValues;
  LoadRoutinesAction({
    this.filter,
    this.completer,
    this.freshValues = false
  });
}
class RoutinesLoadedAction {
  final LinkedHashMap<num, Routine> routines;
  final FilterAndSortable filter;
  final bool freshValues;
  RoutinesLoadedAction({
    this.filter,
    this.freshValues = false,
    this.routines
  });
}

//ExerciseLogs
class LoadExerciseLogsAction {
  Completer completer;
  final FilterAndSortable filter;
  final exerciseId;
  final bool freshValues;
  LoadExerciseLogsAction({
    this.filter,
    this.completer,
    this.freshValues = false,
    this.exerciseId
  });
}
class ExerciseLogsLoadedAction {
  final LinkedHashMap<num, ExerciseLog> exerciseLogs;
  final bool freshValues;
  ExerciseLogsLoadedAction({
    this.freshValues = false,
    this.exerciseLogs
  });
}

//Routines
class LoadSearchRoutinesAction {
  Completer completer;
  final FilterAndSortable filter;
  final bool freshValues;
  LoadSearchRoutinesAction({
    this.filter,
    this.completer,
    this.freshValues = false
  });
}
class SearchRoutinesLoadedAction {
  final LinkedHashMap<num, Routine> searchRoutines;
  final bool freshValues;
  final FilterAndSortable filter;
  SearchRoutinesLoadedAction({
    this.freshValues = false,
    this.searchRoutines,
    this.filter
  });
}





