library exercise_workout;

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'exercise_workout.jser.dart';

class ExerciseWorkout extends BaseModel {
  int id;

  // Defaults
  ExerciseWorkout(){
   sets = 3;
   reps = 2;
   weight = 0.0;
   duration_secs = 0;
  }

  int pos;
  int sets;
  int reps;
  num weight;
  int duration_secs;

  // Relational Models
  Exercise exercise;
  Workout workout;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  int exercise_id;
  int workout_id;

  @override
  String getModelNameForApi() {
    return 'exercise_workouts';
  }
}

@GenSerializer(
    fields: const {
      'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
      'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
      'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
    },
    serializers: const[
      ExerciseJsonSerializer,
      WorkoutJsonSerializer
    ]
)
class ExerciseWorkoutJsonSerializer extends Serializer<ExerciseWorkout> with _$ExerciseWorkoutJsonSerializer{}
