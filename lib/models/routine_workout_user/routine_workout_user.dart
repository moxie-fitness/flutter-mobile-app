library routine_workout_user;

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

part 'routine_workout_user.jser.dart';

class RoutineWorkoutUser extends BaseModel {
  int id;
  DateTime day;

  // Relational Models
  Routine routine;
  Workout workout;
  Moxieuser user;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  int routine_id;
  int workout_id;
  String moxieuser_id;

  @override
  String getModelNameForApi() {
    return 'routine_workout_users';
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
  'day': const EnDecode<DateTime>(
      alias: 'day', processor: const DateTimeSerializer(), isNullable: true),
}, serializers: const [
  RoutineJsonSerializer,
  WorkoutJsonSerializer,
  MoxieuserJsonSerializer
])
class RoutineWorkoutUserJsonSerializer extends Serializer<RoutineWorkoutUser>
    with _$RoutineWorkoutUserJsonSerializer {}
