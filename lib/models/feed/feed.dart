library feed;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'feed.jser.dart';

abstract class FeedRepo {
  Future<Feed> saveFeed(Feed feed);
  Future<List<Feed>> loadFeeds({FilterAndSortable filter});
}

class Feed extends BaseModel {
  int id;

  // Relational Models
  Moxieuser moxieuser;
  Post post;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  String moxieuser_id;
  int post_id;

  @override
  String getModelNameForApi() {
    return 'feeds';
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
      PostJsonSerializer
    ]
)
class FeedJsonSerializer extends Serializer<Feed> with _$FeedJsonSerializer{ }

