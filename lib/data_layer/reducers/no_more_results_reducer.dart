import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:redux/redux.dart';

final allExercisesLoadedReducer = combineReducers<bool>([
  new TypedReducer<bool, ExercisesLoadedAction>((bool state, ExercisesLoadedAction action) {
    return action.exercises != null && action.exercises.isEmpty || action.exercises.length < action.filter.take;
  }),
  new TypedReducer<bool, LoadExercisesAction>((bool state, LoadExercisesAction action) {
    return state ? !action.freshValues : state;
  }),
]);

final allWorkoutsLoadedReducer = combineReducers<bool>([
  new TypedReducer<bool, WorkoutsLoadedAction>((bool state, WorkoutsLoadedAction action) {
    return action.workouts != null &&  action.workouts.isEmpty || action.workouts.length < action.filter.take;
  }),
  new TypedReducer<bool, LoadWorkoutsAction>((bool state, LoadWorkoutsAction action) {
    return action.freshValues;
  }),
]);

final allRoutinesLoadedReducer = combineReducers<bool>([
  new TypedReducer<bool, RoutinesLoadedAction>((bool state, RoutinesLoadedAction action) {
    return action.routines != null &&  action.routines.isEmpty || action.routines.length < action.filter.take;
  }),
  new TypedReducer<bool, LoadRoutinesAction>((bool state, LoadRoutinesAction action) {
    return action.freshValues;
  }),
]);

final allFeedsLoadedReducer = combineReducers<bool>([
  new TypedReducer<bool, FeedsLoadedAction>((bool state, FeedsLoadedAction action) {
    return action.feeds != null &&  action.feeds.isEmpty || action.feeds.length < action.filter.take;
  }),
  new TypedReducer<bool, LoadFeedsAction>((bool state, LoadFeedsAction action) {
    return action.freshValues;
  }),
]);

final allSearchRoutinesLoadedReducer = combineReducers<bool>([
  new TypedReducer<bool, SearchRoutinesLoadedAction>((bool state, SearchRoutinesLoadedAction action) {
    return action.searchRoutines != null &&  action.searchRoutines.isEmpty || action.searchRoutines.length < action.filter.take;
  }),
  new TypedReducer<bool, LoadSearchRoutinesAction>((bool state, LoadSearchRoutinesAction action) {
    return action.freshValues;
  }),
]);