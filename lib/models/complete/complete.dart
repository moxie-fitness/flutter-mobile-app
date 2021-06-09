library completable;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/data_layer/repository/moxie_repository.dart';
import 'package:moxie_fitness/models/models.dart';

part 'complete.jser.dart';

abstract class CompleteRepo {
  Future<Complete> saveComplete(Complete complete);
  Future<List<Complete>> loadCompletesWithRoutineWorkoutUsers(
      DateTime from, DateTime to);
  Future<ResponseWrapper<List<Complete>>>
      loadAllUncompletedCompletesWithRoutineWorkoutUsers();
  Future<Complete> loadComplete(int id);
  Future<ResponseWrapper<Complete>> startActiveRoutine(int id,
      {bool endPrevious = false});
}

class Complete extends BaseModel {
  int id;
  String comment = '';
  String completable = '';
  bool completed = false;

  // Implementers
  Workout workout;
  Routine routine;
  RoutineWorkoutUser routine_workout_user;

  // Relational Models
  Moxieuser moxieuser;

  // Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  String moxieuser_id;
  int completable_id;

  @override
  String getModelNameForApi() {
    return 'completes';
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
  WorkoutJsonSerializer,
  RoutineJsonSerializer,
  MoxieuserJsonSerializer,
  RoutineWorkoutUserJsonSerializer
])
class CompleteJsonSerializer extends Serializer<Complete>
    with _$CompleteJsonSerializer {}
