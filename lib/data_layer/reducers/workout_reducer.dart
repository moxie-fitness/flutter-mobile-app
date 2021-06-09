import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

final workoutsReducer = combineReducers<LinkedHashMap<num, Workout>>([
  new TypedReducer<LinkedHashMap<num, Workout>, WorkoutsLoadedAction>(_setLoadedWorkouts),
  new TypedReducer<LinkedHashMap<num, Workout>, SingleItemLoaded>(_setLoadedWorkout),
  new TypedReducer<LinkedHashMap<num, Workout>, WorkoutSavedAction>(_setSavedWorkout),

]);

LinkedHashMap<num, Workout> _setLoadedWorkouts(LinkedHashMap<num, Workout> workouts, WorkoutsLoadedAction action) {
  if(workouts != null && !action.freshValues) {
    return new LinkedHashMap<num, Workout>.from(workouts)
      ..addAll(action.workouts);
  }
  return action.workouts;
}

LinkedHashMap<num, Workout> _setLoadedWorkout(LinkedHashMap<num, Workout> workouts, SingleItemLoaded action) {
  if(action.type == EModelTypes.workout) {
    if(workouts == null) {
      return new LinkedHashMap<num, Workout>()..putIfAbsent(action.item.moxieuserId,() => action.item);
    }
    // Remove, if already existed, to update with new entry;
    workouts.remove(action.item?.moxieuserId);
    return workouts..putIfAbsent(action.item?.moxieuserId, () => action.item);
  }
  return workouts;
}

LinkedHashMap<num, Workout> _setSavedWorkout(LinkedHashMap<num, Workout> workouts, WorkoutSavedAction action) {
  if(workouts == null) {
    return new LinkedHashMap<num, Workout>()..putIfAbsent(action.workout.id,() => action.workout);
  }
  return workouts..putIfAbsent(action.workout.id,() => action.workout);
}