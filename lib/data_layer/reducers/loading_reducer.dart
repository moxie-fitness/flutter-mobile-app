import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';
import 'package:moxie_fitness/data_layer/app/moxie_view_loaders_state.dart';
import 'package:redux/redux.dart';

final loadingReducer = combineReducers<bool>([
  new TypedReducer<bool, MoxieuserLoadedAction>(_setLoaded),
  new TypedReducer<bool, ExercisesLoadedAction>(_setLoaded),
  new TypedReducer<bool, WorkoutsLoadedAction>(_setLoaded),
  new TypedReducer<bool, RoutinesLoadedAction>(_setLoaded),
  new TypedReducer<bool, FeedsLoadedAction>(_setLoaded),
  new TypedReducer<bool, SearchRoutinesLoadedAction>(_setLoaded),
  new TypedReducer<bool, LoadExercisesAction>(_setLoading),
  new TypedReducer<bool, LoadMoxieuserAction>(_setLoading),
  new TypedReducer<bool, LoadWorkoutsAction>(_setLoading),
  new TypedReducer<bool, LoadRoutinesAction>(_setLoading),
  new TypedReducer<bool, LoadFeedsAction>(_setLoading),
  new TypedReducer<bool, LoadSearchRoutinesAction>(_setLoading),
]);

bool _setLoaded(bool state, action) {
  return false;
}

bool _setLoading(bool state, action) {
  return true;
}

final viewLoadersReducer = combineReducers<MoxieViewLoadersState>([
  new TypedReducer<MoxieViewLoadersState, FeedsLoadedAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: false,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: state.workoutsListLoading,
        routinesListLoading: state.routinesListLoading,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, ExercisesLoadedAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state?.feedsListLoading,
        exercisesListLoading: false,
        workoutsListLoading: state.workoutsListLoading,
        routinesListLoading: state.routinesListLoading,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, WorkoutsLoadedAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state.feedsListLoading,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: false,
        routinesListLoading: state.routinesListLoading,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, RoutinesLoadedAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state.feedsListLoading,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: state.workoutsListLoading,
        routinesListLoading: false,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, SearchRoutinesLoadedAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state.feedsListLoading,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: state.workoutsListLoading,
        routinesListLoading: state.routinesListLoading,
        searchRoutinesListLoading: false);
  }),
  new TypedReducer<MoxieViewLoadersState, LoadFeedsAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: true,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: state.workoutsListLoading,
        routinesListLoading: state.routinesListLoading,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, LoadExercisesAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state?.feedsListLoading,
        exercisesListLoading: true,
        workoutsListLoading: state?.workoutsListLoading,
        routinesListLoading: state?.routinesListLoading,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, LoadWorkoutsAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state.feedsListLoading,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: true,
        routinesListLoading: state.routinesListLoading,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, LoadRoutinesAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state.feedsListLoading,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: state.workoutsListLoading,
        routinesListLoading: true,
        searchRoutinesListLoading: state.searchRoutinesListLoading);
  }),
  new TypedReducer<MoxieViewLoadersState, LoadSearchRoutinesAction>(
      (MoxieViewLoadersState state, action) {
    return new MoxieViewLoadersState(
        feedsListLoading: state.feedsListLoading,
        exercisesListLoading: state.exercisesListLoading,
        workoutsListLoading: state.workoutsListLoading,
        routinesListLoading: state.routinesListLoading,
        searchRoutinesListLoading: true);
  }),
]);
