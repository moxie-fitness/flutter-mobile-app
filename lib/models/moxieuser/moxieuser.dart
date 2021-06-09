library moxieuser;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

part 'moxieuser.jser.dart';

abstract class MoxieuserRepo {
  Future<Moxieuser> loadMoxieuser();
  Future<bool> saveMoxieuserDetails(Moxieuser moxieusuer);
}

class Moxieuser extends BaseModel {
  static final String MOXIE = 'Moxie_Fitness_Id';

  String id;
  String username;
  String email;
  bool is_public;
  bool gender; // true => male
  bool unit; // true => metric
  String firebase_fcm_token;
  String stipe_user_id;
  List<String> media = new List<String>();

  // Relational Models
//  List<RoutineSubscription> routineSubscriptions;
  List<Height> heights;
  List<Weight> weights;
  List<Moxie> moxies;

//  List<RoutineWorkoutUser> userWorkoutsActivity;
//  List<ExerciseLog> exerciseLogs;

  bool needsRegistrationDetails() {
    return heights == null ||
        heights.isEmpty ||
        weights == null ||
        weights.isEmpty ||
        username == null ||
        username.isEmpty;
  }

  @override
  String getModelNameForApi() {
    return 'moxieusers';
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
  HeightJsonSerializer,
  WeightJsonSerializer,
  MoxieJsonSerializer
])
class MoxieuserJsonSerializer extends Serializer<Moxieuser>
    with _$MoxieuserJsonSerializer {}
