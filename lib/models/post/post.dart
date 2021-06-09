library postable;

import 'dart:async';
import 'dart:core';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

part 'post.jser.dart';

abstract class PostRepo {
  Future<Post> savePost(Post post);
}

class Post extends BaseModel {
  int id;
  String content;
  List<String> media;

  // Implementers
  Routine routine;
  Workout workout;
  Exercise exercise;
  Complete completable;

  // Inverse Relation
  List<Comment> comments;
  List<Rating> ratings = <Rating>[];

  // Relational Models
  Moxieuser moxieuser;

  int getLikes() {
    return (ratings?.where((Rating r) => r.value > 0) ?? []).length;
  }

  @override
  String getModelNameForApi() {
    return 'posts';
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
  RoutineJsonSerializer,
  WorkoutJsonSerializer,
  ExerciseJsonSerializer,
  CompleteJsonSerializer,
  CommentJsonSerializer,
  RatingJsonSerializer,
  MoxieuserJsonSerializer
])
class PostJsonSerializer extends Serializer<Post> with _$PostJsonSerializer {}
