library lookup_option;

import 'dart:async';
import 'dart:convert';

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:http/http.dart' as http;
import 'package:moxie_fitness/models/repo.dart';

part 'lookup_option.jser.dart';

abstract class LookupOptionRepo {
  Future<List<LookupOption>> loadLookupOptions(String orLookupValue);
}

class LookupOption extends BaseModel {
  int id;
  String value;
  Map<String, String> opt;

  // Relational Models
  Lookup lookup;

  /// Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  int lookup_id;

  @override
  String getModelNameForApi() {
    return 'lookup_options';
  }
}

@GenSerializer(
  fields: const {
    'created_at': const EnDecode<DateTime>(alias: 'created_at', processor: const DateTimeSerializer(), isNullable: true),
    'updated_at': const EnDecode<DateTime>( alias: 'updated_at', processor: const DateTimeSerializer(), isNullable: true),
    'deleted_at': const EnDecode<DateTime>( alias: 'deleted_at', processor: const DateTimeSerializer(), isNullable: true),
  },
  serializers: const [
    LookupJsonSerializer
  ]
)
class LookupOptionJsonSerializer extends Serializer<LookupOption> with _$LookupOptionJsonSerializer {

}
