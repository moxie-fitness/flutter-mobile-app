library exercise;

import 'dart:async';
import 'dart:convert';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:meta/meta.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:moxie_fitness/models/repo.dart';
import 'package:moxie_fitness/models/utils/filterable.dart';

part 'exercise.jser.dart';

abstract class ExerciseRepo {
  Future<List<Exercise>> loadExercises({FilterAndSortable filter});
  Future<Exercise> saveExercise(Exercise exercise);
  Future<Exercise> loadExercise(int id);
}

class Exercise extends BaseModel {
  int id;
  String name;
  String youtube_url;

  // Relational Models
  Post post;
  Moxieuser createdByUser;
  LookupOption muscle;
  List<ExerciseEquipment> equipment;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  String moxieuser_id;
  int muscle_id;
  int post_id;

  // Variables set via redux reducers
  List<ExerciseLog> exerciseLogs = <ExerciseLog>[];

  static final jsonRepo = new JsonRepo()
    ..add(new PostJsonSerializer())
    ..add(new ExerciseJsonSerializer())
    ..add(new ExerciseEquipmentJsonSerializer())
    ..add(new LookupOptionJsonSerializer());

  static Future<bool> machineOrEquipment(int id, List<LookupOption> items, {bool attach = true}) async {
    var url = '${BaseModel.getApiBaseUrl}exercises/${attach ? 'attach' : 'detach'}-many-machine';
    var equipment = jsonRepo.encode(items);
    Map body = new Map()
      ..putIfAbsent('id', () => '$id')
      ..putIfAbsent('equipment', () => equipment);
    var response = await http.post('$url', headers: await BaseModel.getAuthHeader(ContentType.urlencoded), body: body);
    Map map = json.decode(response.body);
    bool decoded = map['success'];
    return decoded;
  }

  @override
  String getModelNameForApi() {
    return 'exercises';
  }
}

@GenSerializer(
  fields: const {
    'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
    'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
    'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
  },
  serializers: const[
    PostJsonSerializer,
    MoxieuserJsonSerializer,
    LookupOptionJsonSerializer,
    ExerciseEquipmentJsonSerializer,
    ExerciseLogJsonSerializer
  ]
)
class ExerciseJsonSerializer extends Serializer<Exercise> with _$ExerciseJsonSerializer {}
