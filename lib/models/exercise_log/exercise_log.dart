library exercise_log;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

part 'exercise_log.jser.dart';

abstract class ExerciseLogRepo {
  Future<List<ExerciseLog>> loadExerciseLogs({FilterAndSortable filter, int exercise_id});
  Future<ExerciseLog> saveExerciseLog(ExerciseLog exerciseLog);
}

class ExerciseLog extends BaseModel {
  int id;
  int sets;
  int reps;
  num weight;
  int duration_secs;

  // Relational Models
  Moxieuser logByUser;
  Exercise exercise;
  Complete completedWorkout;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  String moxieuser_id;
  int exercise_id;
  int completed_workout_id;

  @override
  String getModelNameForApi() {
    return 'exercise_logs';
  }
}

@GenSerializer(
    fields: const {
      'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
      'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
      'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
    },
    serializers: const[
      MoxieuserJsonSerializer,
      ExerciseJsonSerializer,
      CompleteJsonSerializer
    ]
)
class ExerciseLogJsonSerializer extends Serializer<ExerciseLog> with _$ExerciseLogJsonSerializer {}
