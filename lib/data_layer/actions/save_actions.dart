import 'package:moxie_fitness/models/models.dart';

typedef void OnItemSavedCallback<T>(T itemToSave);

enum EModelTypes {
  exercise,
  workout,
  routine,
  exerciseLog,
  post,
  feed,
  completableWorkout,
  routineSubscription,
  rating,
  comment
}

class SaveAction<T> {
  final T item;
  final EModelTypes type;
  final OnItemSavedCallback<T> onSavedCallback;
  SaveAction({this.item, this.type, this.onSavedCallback});
}

class OnSavedAction<T> {
  final T item;
  final EModelTypes type;
  OnSavedAction({this.item, this.type});
}

class ExerciseSavedAction {
  final Exercise exercise;
  ExerciseSavedAction({this.exercise});
}

class WorkoutSavedAction {
  final Workout workout;
  WorkoutSavedAction({this.workout});
}

class RoutineSavedAction {
  final Routine routine;
  RoutineSavedAction({this.routine});
}
