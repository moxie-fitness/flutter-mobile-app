
import 'package:meta/meta.dart';
import 'package:moxie_fitness/models/models.dart';

enum ELookups {
  goals,
  muscles,
  equipment
}

const Map<ELookups, String> globalLookupsMap = const {
  ELookups.goals: 'goals',
  ELookups.muscles: 'muscles',
  ELookups.equipment: 'machine.or.equipment',
};

class LoadLookupOptions{
  final ELookups eLookup;
  LoadLookupOptions({
    @required this.eLookup
  });
}

class MuscleLookupOptionsLoadedAction {
  final List<LookupOption> lookupOptions;
  MuscleLookupOptionsLoadedAction({
    this.lookupOptions
  });
}
class EquipmentLookupOptionsLoadedAction {
  final List<LookupOption> lookupOptions;
  EquipmentLookupOptionsLoadedAction({
    this.lookupOptions
  });
}
class GoalsLookupOptionsLoadedAction {
  final List<LookupOption> lookupOptions;
  GoalsLookupOptionsLoadedAction({
    this.lookupOptions
  });
}
