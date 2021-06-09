import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

final routinesReducer = combineReducers<LinkedHashMap<num, Routine>>([
  new TypedReducer<LinkedHashMap<num, Routine>, RoutinesLoadedAction>(_setLoadedRoutines),
  new TypedReducer<LinkedHashMap<num, Routine>, SingleItemLoaded>(_setLoadedRoutine),
  new TypedReducer<LinkedHashMap<num, Routine>, RoutineSavedAction>(_setSavedRoutine),
]);

LinkedHashMap<num, Routine> _setLoadedRoutines(LinkedHashMap<num, Routine> routines, RoutinesLoadedAction action) {
  if(routines != null && !action.freshValues) {
    return new LinkedHashMap<num, Routine>.from(routines)
      ..addAll(action.routines);
  }
  return action.routines;
}

LinkedHashMap<num, Routine> _setLoadedRoutine(LinkedHashMap<num, Routine> routines, SingleItemLoaded action) {
  if(action.type == EModelTypes.routine) {
    if(routines == null) {
      return new LinkedHashMap<num, Routine>()..putIfAbsent(action.item.moxieuserId,() => action.item);
    }
    // Remove, if already existed, to update with new entry;
    routines.remove(action.item.moxieuserId);
    return routines..putIfAbsent(action.item.moxieuserId,() => action.item);
  }
  return routines;
}

LinkedHashMap<num, Routine> _setSavedRoutine(LinkedHashMap<num, Routine> routines, RoutineSavedAction action) {
  if(routines == null) {
    return new LinkedHashMap<num, Routine>()..putIfAbsent(action.routine.id,() => action.routine);
  }
  return routines..putIfAbsent(action.routine.id,() => action.routine);
}