import 'package:moxie_fitness/data_layer/app/feeds_state.dart';
import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/data_layer/reducers/reducers.dart';

MoxieAppState appReducer(MoxieAppState state, action) {
  return new MoxieAppState(
    viewLoadersState: viewLoadersReducer(state.viewLoadersState, action),
    isLoading: loadingReducer(state.isLoading, action),
    moxieuser: moxieuserReducer(state.moxieuser, action),
    exercises: exercisesReducer(state.exercises, action),
    workouts: workoutsReducer(state.workouts, action),
    routines: routinesReducer(state.routines, action),
    searchRoutines: searchRoutinesReducer(state.searchRoutines, action),
    allExercisesLoaded: allExercisesLoadedReducer(state.allExercisesLoaded, action),
    allWorkoutsLoaded: allWorkoutsLoadedReducer(state.allWorkoutsLoaded, action),
    allRoutinesLoaded: allRoutinesLoadedReducer(state.allRoutinesLoaded, action),
    allSearchRoutinesLoaded: allSearchRoutinesLoadedReducer(state.allSearchRoutinesLoaded, action),
    muscleLookupOptions: muscleLookupOptionsReducer(state.muscleLookupOptions, action),
    equipmentLookupOptions: equipmentLookupOptionsReducer(state.equipmentLookupOptions, action),
    goalsLookupOptions: goalsLookupOptionsReducer(state.goalsLookupOptions, action),
    completesState: completesReducer(state.completesState, action),
    feedsState: FeedsState(
      feeds: feedsReducer(state.feedsState?.feeds, action),
      allFeedsLoaded: allFeedsLoadedReducer(state.feedsState?.allFeedsLoaded, action)
    ),
  );
}