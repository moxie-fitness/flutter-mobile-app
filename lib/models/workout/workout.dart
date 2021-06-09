library workout;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'workout.jser.dart';

abstract class WorkoutRepo {
  Future<List<Workout>> loadWorkouts({FilterAndSortable filter});
  Future<Workout> saveWorkout(Workout workout);
  Future<Workout> loadWorkout(int id);
}

class Workout extends BaseModel {
  int id;
  String name;

  // Relational Models
  Moxieuser moxieuser;
  LookupOption difficulty;
  Post post;
  List<ExerciseWorkout> workout_exercises;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  String moxieuser_id;
  int post_id;
  int difficulty_id;

  @override
  String getModelNameForApi() {
    return 'workouts';
  }
}

@GenSerializer(fields: const {
  'created_at': const EnDecode<DateTime>(
      alias: 'created_at',
      processor: const DateTimeSerializer(),
      isNullable: true),
  'updated_at': const EnDecode<DateTime>(
      alias: 'updated_at',
      processor: const DateTimeSerializer(),
      isNullable: true),
  'deleted_at': const EnDecode<DateTime>(
      alias: 'deleted_at',
      processor: const DateTimeSerializer(),
      isNullable: true),
}, serializers: const [
  MoxieuserJsonSerializer,
  PostJsonSerializer,
  ExerciseJsonSerializer,
  ExerciseWorkoutJsonSerializer,
  LookupOptionJsonSerializer
])
class WorkoutJsonSerializer extends Serializer<Workout>
    with _$WorkoutJsonSerializer {}
