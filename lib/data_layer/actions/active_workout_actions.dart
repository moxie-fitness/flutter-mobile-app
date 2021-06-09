import 'package:moxie_fitness/models/models.dart';

class AddExerciseLogToActiveWorkoutAction {
  final ExerciseLog log;

  AddExerciseLogToActiveWorkoutAction(this.log);
}

class ClearActiveWorkoutAction {}

class SetActiveWorkoutCompletableAction {
  final Complete completableWorkout;
  SetActiveWorkoutCompletableAction({
    this.completableWorkout
  });
}

