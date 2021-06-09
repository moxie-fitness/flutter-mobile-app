library notification_payload;

import 'package:jaguar_serializer/jaguar_serializer.dart';

part 'notification_payload.jser.dart';

class NotificationPayload {
  final String fullRoute;
  final String itemId;

  NotificationPayload({this.fullRoute, this.itemId});
}

@GenSerializer(fields: const {}, serializers: const [])
class NotificationPayloadJsonSerializer extends Serializer<NotificationPayload>
    with _$NotificationPayloadJsonSerializer {}
