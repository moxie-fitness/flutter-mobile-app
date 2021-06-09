library exercise_machine_or_equipment;

import 'package:jaguar_serializer/jaguar_serializer.dart';
import 'package:moxie_fitness/models/models.dart';

part 'exercise_equipment.jser.dart';

class ExerciseEquipment extends BaseModel {
  int id;
  // Relational Models
  Exercise exercise;
  LookupOption equipment;

  // Reference Id Fields : Useful for still looking up a relation if the relation is originally not queried
  @Alias('exercise_id')
  int exerciseId;
  @Alias('equipment_id')
  int equipmentId;

  @override
  String getModelNameForApi() {
    return 'exercise_equipments';
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
  ExerciseJsonSerializer,
  LookupOptionJsonSerializer
])
class ExerciseEquipmentJsonSerializer extends Serializer<ExerciseEquipment>
    with _$ExerciseEquipmentJsonSerializer {}
