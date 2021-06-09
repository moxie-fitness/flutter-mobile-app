library height;

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:moxie_fitness/models/repo.dart';

part 'height.jser.dart';

class Height extends BaseModel {
  int id;
  num value;

  // Relational Models
  Moxieuser moxieuser;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  String moxieuser_id;

  @override
  String getModelNameForApi() {
    return 'heights';
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
class HeightJsonSerializer extends Serializer<Height> with _$HeightJsonSerializer{ }

