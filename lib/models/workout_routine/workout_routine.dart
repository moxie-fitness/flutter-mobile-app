library workout_routine;

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'workout_routine.jser.dart';

class WorkoutRoutine extends BaseModel {
  int id;
  int pos;
  int week;

  WorkoutRoutine();

  WorkoutRoutine.createRoutinePage({
    this.pos,
    this.week,
    this.workout_id,
  });

  // Relational Models
  Workout workout;
  Routine routine;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  int workout_id;
  int routine_id;

  @override
  String getModelNameForApi() {
    return 'workout_routines';
  }

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
      other is WorkoutRoutine &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        pos == other.pos &&
        week == other.week;

  @override
  int get hashCode =>
    id.hashCode ^
    pos.hashCode ^
    week.hashCode ^
    workout.hashCode ^
    routine.hashCode ^
    workout_id.hashCode ^
    routine_id.hashCode;
}

@GenSerializer(
    fields: const {
      'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
      'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
      'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
    },
    serializers: const[
      WorkoutJsonSerializer,
      RoutineJsonSerializer
    ]
)
class WorkoutRoutineJsonSerializer extends Serializer<WorkoutRoutine> with _$WorkoutRoutineJsonSerializer {}