import 'dart:collection';

import 'package:moxie_fitness/models/models.dart';

class CompletesState {
  final Complete activeWorkout;
  final Complete activeRoutine;
  final LinkedHashMap<num, Complete> calendarCompletesWorkouts;
  final List<ExerciseLog> activeWorkoutLogs;

  CompletesState({
    this.activeWorkout,
    this.activeRoutine,
    this.calendarCompletesWorkouts,
    this.activeWorkoutLogs
  });

  @override
  int get hashCode =>
    activeWorkout.hashCode ^
    activeRoutine.hashCode ^
    calendarCompletesWorkouts.hashCode ^
    activeWorkoutLogs.hashCode;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is CompletesState &&
        runtimeType == other.runtimeType &&
        activeWorkout == other.activeWorkout &&
        activeRoutine == other.activeRoutine &&
        calendarCompletesWorkouts == other.calendarCompletesWorkouts &&
        activeWorkoutLogs == other.activeWorkoutLogs;
}