library commentable;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

part 'comment.jser.dart';

abstract class CommentRepo {
  Future<Comment> saveComment(Comment comment);
  Future<List<Comment>> loadCommentsForPost(
      {int postId, FilterAndSortable filter});
}

class Comment extends BaseModel {
  int id;
  String content;
  List<String> media;

  // Inverse Relation
  List<Rating> ratings = <Rating>[];

  // Relational Models
  Moxieuser moxieuser;
  Post post;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  @Alias('moxieuser_id')
  String moxieuserId;
  @Alias('post_id')
  int postId;

  int getLikes() {
    return (ratings?.where((Rating r) => r.value > 0) ?? []).length;
  }

  @override
  String getModelNameForApi() {
    return 'comments';
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
  MoxieuserJsonSerializer,
  RatingJsonSerializer,
  PostJsonSerializer
])
class CommentJsonSerializer extends Serializer<Comment>
    with _$CommentJsonSerializer {}
