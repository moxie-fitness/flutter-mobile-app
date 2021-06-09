import 'dart:collection';

import 'package:moxie_fitness/data_layer/app/moxie_app_state.dart';
import 'package:moxie_fitness/models/models.dart';

bool isLoadingSelector(MoxieAppState state) => state.isLoading;

Workout workoutSelector(LinkedHashSet<Workout> workouts, int id) {
  try {
    return workouts.firstWhere((w) => w.id == id);
  } catch (e) {
    return null;
  }
}
