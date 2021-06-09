import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/completes_state.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

final completesReducer = combineReducers<CompletesState>([
  new TypedReducer<CompletesState, SetActiveWorkoutCompletableAction>(
      _setActiveCompletableWorkout),
  new TypedReducer<CompletesState, AddExerciseLogToActiveWorkoutAction>(
      _addLogToActiveWorkout),
  new TypedReducer<CompletesState, ClearActiveWorkoutAction>(
      _clearActiveWorkout),
  new TypedReducer<CompletesState, SetActiveRoutineCompletableAction>(
      _setActiveRoutineCompletable),
  new TypedReducer<CompletesState, OnLoadedCompletesForCalendar>(
      _setLoadedCompletesForCalendar)
]);

CompletesState _setActiveCompletableWorkout(
    CompletesState state, SetActiveWorkoutCompletableAction action) {
  return CompletesState(
      activeWorkout: action.completableWorkout,
      activeRoutine: state?.activeRoutine,
      calendarCompletesWorkouts: state?.calendarCompletesWorkouts,
      activeWorkoutLogs: state?.activeWorkoutLogs);
}

CompletesState _addLogToActiveWorkout(
    CompletesState state, AddExerciseLogToActiveWorkoutAction action) {
  List<ExerciseLog> logs = <ExerciseLog>[];
  if (state?.activeWorkoutLogs == null) {
    logs.add(action.log);
  } else {
    logs = List<ExerciseLog>.from(state.activeWorkoutLogs)..add(action.log);
  }
  return CompletesState(
      activeWorkout: state?.activeWorkout,
      activeRoutine: state?.activeRoutine,
      calendarCompletesWorkouts: state?.calendarCompletesWorkouts,
      activeWorkoutLogs: logs);
}

CompletesState _clearActiveWorkout(
    CompletesState state, ClearActiveWorkoutAction action) {
  return CompletesState(
      activeWorkout: null,
      activeRoutine: state?.activeRoutine,
      calendarCompletesWorkouts: state?.calendarCompletesWorkouts,
      activeWorkoutLogs: null);
}

CompletesState _setActiveRoutineCompletable(
    CompletesState state, SetActiveRoutineCompletableAction action) {
  return CompletesState(
      activeWorkout: state?.activeWorkout,
      activeRoutine: action.completableRoutine,
      calendarCompletesWorkouts: state?.calendarCompletesWorkouts,
      activeWorkoutLogs: state?.activeWorkoutLogs);
}

CompletesState _setLoadedCompletesForCalendar(
    CompletesState state, OnLoadedCompletesForCalendar action) {
  var calendarCompletes = new LinkedHashMap<num, Complete>();
  if (state?.calendarCompletesWorkouts == null || action.fresh) {
    calendarCompletes = action.calendarCompletes;
  } else {
    calendarCompletes =
        new LinkedHashMap<num, Complete>.from(state.calendarCompletesWorkouts)
          ..addAll(action.calendarCompletes);
  }
  return CompletesState(
      activeWorkout: state?.activeWorkout,
      activeRoutine: state?.activeRoutine,
      calendarCompletesWorkouts: calendarCompletes,
      activeWorkoutLogs: state?.activeWorkoutLogs);
}
