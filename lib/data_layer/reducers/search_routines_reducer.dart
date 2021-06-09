import 'dart:collection';

import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

final searchRoutinesReducer = combineReducers<LinkedHashMap<num, Routine>>([
  new TypedReducer<LinkedHashMap<num, Routine>, SearchRoutinesLoadedAction>(_setLoadedRoutines),
]);

LinkedHashMap<num, Routine> _setLoadedRoutines(LinkedHashMap<num, Routine> routines, SearchRoutinesLoadedAction action) {
  if(routines != null && !action.freshValues) {
    return new LinkedHashMap<num, Routine>.from(routines)
      ..addAll(action.searchRoutines);
  } else if(action.freshValues && action.searchRoutines != null) {
    return action.searchRoutines;
  }
  return routines;
}
