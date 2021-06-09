library routine;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/repo.dart';
import '../models.dart';

part 'routine.jser.dart';

abstract class RoutineRepo {
  Future<List<Routine>> loadRoutines({FilterAndSortable filter});
  Future<Routine> saveRoutine(Routine routine);
  Future<Routine> loadRoutine(int id);
}

class Routine extends BaseModel {
  int id;
  String name;
  num price;
  bool is_public;

  // Inverse Relationships
//  List<Comment> reviews;
//  List<Rating> ratings;

  // Relational Models
  Moxieuser moxieuser;
  LookupOption goal;
  List<RoutineSubscription> routine_subscriptions;
  List<WorkoutRoutine> routine_workouts;
  Post post;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  int goal_id;
  int post_id;
  String moxieuser_id;

  @override
  String getModelNameForApi() {
    return 'routines';
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
    LookupOptionJsonSerializer,
    RoutineSubscriptionJsonSerializer,
    WorkoutRoutineJsonSerializer,
    PostJsonSerializer
  ]
)
class RoutineJsonSerializer extends Serializer<Routine> with _$RoutineJsonSerializer{}
