import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';


final muscleLookupOptionsReducer = combineReducers<List<LookupOption>>([
  new TypedReducer<List<LookupOption>, MuscleLookupOptionsLoadedAction>(_setLoadedMuscleLookupOptions),
]);

List<LookupOption> _setLoadedMuscleLookupOptions(List<LookupOption> lookupOptions, MuscleLookupOptionsLoadedAction action) {
  return action.lookupOptions;
}



final equipmentLookupOptionsReducer = combineReducers<List<LookupOption>>([
  new TypedReducer<List<LookupOption>, EquipmentLookupOptionsLoadedAction>(_setLoadedEquipmentLookupOptions),
]);

List<LookupOption> _setLoadedEquipmentLookupOptions(List<LookupOption> lookupOptions, EquipmentLookupOptionsLoadedAction action) {
  return action.lookupOptions;
}



final goalsLookupOptionsReducer = combineReducers<List<LookupOption>>([
  new TypedReducer<List<LookupOption>, GoalsLookupOptionsLoadedAction>(_setLoadedGoalsLookupOptions),
]);

List<LookupOption> _setLoadedGoalsLookupOptions(List<LookupOption> lookupOptions, GoalsLookupOptionsLoadedAction action) {
  return action.lookupOptions;
}
