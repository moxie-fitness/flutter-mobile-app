library routine_subscription;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'routine_subscription.jser.dart';

abstract class RoutineSubscriptionRepo {
  Future<RoutineSubscription> saveRoutineSubscription(RoutineSubscription rs);
  Future<bool> checkIfSubscribed(int routineId);
}

class RoutineSubscription extends BaseModel{
  int id;
  String payout_batch_id; // doesn't reference another model in our DB
  DateTime payout_time;

  //Relational Models
  Routine routine;
  Moxieuser subscriberUser;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  int routine_id;
  String subscriber_moxieuser_id;

  @override
  String getModelNameForApi() {
    return 'routine_subscriptions';
  }
}

@GenSerializer(
    fields: const {
      'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
      'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
      'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
    },
    serializers: const[
      RoutineJsonSerializer,
      MoxieuserJsonSerializer
    ]
)
class RoutineSubscriptionJsonSerializer extends Serializer<RoutineSubscription> with _$RoutineSubscriptionJsonSerializer {}
