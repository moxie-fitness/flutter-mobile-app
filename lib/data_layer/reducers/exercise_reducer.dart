import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

final exercisesReducer = combineReducers<LinkedHashMap<num, Exercise>>([
  new TypedReducer<LinkedHashMap<num, Exercise>, ExercisesLoadedAction>(
      _setLoadedExercises),
  new TypedReducer<LinkedHashMap<num, Exercise>, SingleItemLoaded>(
      _setLoadedExercise),
  new TypedReducer<LinkedHashMap<num, Exercise>, ExerciseSavedAction>(
      _setSavedExercise),
]);

LinkedHashMap<num, Exercise> _setLoadedExercises(
    LinkedHashMap<num, Exercise> exercises, ExercisesLoadedAction action) {
  if (exercises != null && !action.freshValues) {
    return new LinkedHashMap<num, Exercise>.from(exercises)
      ..addAll(action.exercises);
  }
  return action.exercises;
}

LinkedHashMap<num, Exercise> _setLoadedExercise(
    LinkedHashMap<num, Exercise> exercises, SingleItemLoaded action) {
  if (action.type == EModelTypes.exercise) {
    if (exercises == null) {
      return new LinkedHashMap<num, Exercise>()
        ..putIfAbsent(action.item.id, () => action.item);
    } else {
      return exercises
        ..update(action.item.id, (v) => action.item,
            ifAbsent: () => action.item);
    }
  }
  return exercises;
}

LinkedHashMap<num, Exercise> _setSavedExercise(
    LinkedHashMap<num, Exercise> exercises, ExerciseSavedAction action) {
  if (exercises == null) {
    return new LinkedHashMap<num, Exercise>()
      ..putIfAbsent(action.exercise.id, () => action.exercise);
  }
  return exercises..putIfAbsent(action.exercise.id, () => action.exercise);
}
