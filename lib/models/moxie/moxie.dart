library motivation;

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'moxie.jser.dart';

class Moxie extends BaseModel {
  int id;

  // Relational Models
  Moxieuser fromUser;
  Moxieuser toUser;

  /** Reference Id Fields : Useful for still looking up a relation IF the relation was originally not queried **/
  String from_moxieuser_id;
  String to_moxieuser_id;

  @override
  String getModelNameForApi() {
    return 'moxies';
  }
}

@GenSerializer(
    fields: const {
      'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
      'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
      'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
    },
    serializers: const[
      MoxieuserJsonSerializer
    ]
)
class MoxieJsonSerializer extends Serializer<Moxie> with _$MoxieJsonSerializer{

}
