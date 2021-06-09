library lookup;

import 'dart:async';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

part 'lookup.jser.dart';

abstract class LookupRepo {
  Future<Lookup> loadLookup(String value);
}

class Lookup extends BaseModel {
  int id;
  String value;

  @override
  String getModelNameForApi() {
    return 'lookups';
  }
}

@GenSerializer(
  fields: const {
    'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
    'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
    'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
  },
  serializers: const[
  ]
)
class LookupJsonSerializer extends Serializer<Lookup> with _$LookupJsonSerializer {
  Lookup createModel() => new Lookup();
}
