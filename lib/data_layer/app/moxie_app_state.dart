import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:moxie_fitness/data_layer/app/completes_state.dart';
import 'package:moxie_fitness/data_layer/app/feeds_state.dart';
import 'package:moxie_fitness/data_layer/app/moxie_view_loaders_state.dart';
import 'package:moxie_fitness/models/models.dart';

@immutable
class MoxieAppState {
  final bool isLoading;

  final MoxieViewLoadersState viewLoadersState;

  final Moxieuser moxieuser;
//
  final FeedsState feedsState;

  final bool allExercisesLoaded;
  final LinkedHashMap<num, Exercise> exercises;

  final bool allWorkoutsLoaded;
  final LinkedHashMap<num, Workout> workouts;

  final bool allRoutinesLoaded;
  final LinkedHashMap<num, Routine> routines;

  final bool allSearchRoutinesLoaded;
  final LinkedHashMap<num, Routine> searchRoutines;

  // Exercise Logs Map <ExerciseId, List<ExerciseLog>>
  final HashMap<int, List<ExerciseLog>> exerciseLogs;

  final List<LookupOption> muscleLookupOptions;
  final List<LookupOption> equipmentLookupOptions;
  final List<LookupOption> goalsLookupOptions;

  final CompletesState completesState;

  MoxieAppState({
    this.viewLoadersState,
    this.moxieuser,
    this.feedsState,
    this.exercises,
    this.allExercisesLoaded = false,
    this.workouts,
    this.allWorkoutsLoaded = false,
    this.routines,
    this.exerciseLogs,
    this.allRoutinesLoaded = false,
    this.allSearchRoutinesLoaded = false,
    this.searchRoutines,
    this.isLoading = false,
    this.muscleLookupOptions,
    this.equipmentLookupOptions,
    this.goalsLookupOptions,
    this.completesState,
  });

  factory MoxieAppState.loading() => new MoxieAppState(
    isLoading: true,
    viewLoadersState: new MoxieViewLoadersState(
      feedsListLoading: false,
      exercisesListLoading: false,
      workoutsListLoading: false,
      routinesListLoading: false
    )
  );

  @override
  int get hashCode =>
    isLoading.hashCode ^
    viewLoadersState.hashCode ^
    moxieuser.hashCode ^
    feedsState.hashCode ^
    exercises.hashCode ^
    muscleLookupOptions.hashCode ^
    equipmentLookupOptions.hashCode ^
    workouts.hashCode ^
    allExercisesLoaded.hashCode ^
    goalsLookupOptions.hashCode ^
    allSearchRoutinesLoaded.hashCode ^
    searchRoutines.hashCode ^
    completesState.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is MoxieAppState &&
        runtimeType == other.runtimeType &&
        isLoading == other.isLoading &&
        viewLoadersState == other.viewLoadersState &&
        moxieuser == other.moxieuser &&
        feedsState == other.feedsState &&
        exercises == other.exercises &&
        muscleLookupOptions == other.muscleLookupOptions &&
        equipmentLookupOptions == other.equipmentLookupOptions &&
        workouts == other.workouts &&
        allWorkoutsLoaded == other.allWorkoutsLoaded &&
        goalsLookupOptions == other.goalsLookupOptions &&
        searchRoutines == other.searchRoutines &&
        allSearchRoutinesLoaded == other.allSearchRoutinesLoaded &&
        completesState == other.completesState;
}
