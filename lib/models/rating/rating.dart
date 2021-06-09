library ratable;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'rating.jser.dart';

abstract class RatingRepo {
  Future<Rating> saveRating(Rating rating);
}

class Rating extends BaseModel {
  int id;
  int value;
  String ratable;

  // Implementers
  Routine routine;
  Post postable;

  // Relational Models
  Moxieuser user;

  // Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  String moxieuser_id;
  int ratable_id;

  @override
  String getModelNameForApi() {
    return 'ratings';
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
      RoutineJsonSerializer,
      PostJsonSerializer
    ]
)
class RatingJsonSerializer extends Serializer<Rating> with _$RatingJsonSerializer {}

