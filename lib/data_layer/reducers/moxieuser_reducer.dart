import 'package:moxie_fitness/data_layer/actions/actions.dart';
import 'package:moxie_fitness/models/models.dart';
import 'package:redux/redux.dart';

final moxieuserReducer = combineReducers<Moxieuser>([
  new TypedReducer<Moxieuser, MoxieuserLoadedAction>(_setLoadedMoxieuser),
]);

Moxieuser _setLoadedMoxieuser(Moxieuser moxieuser, MoxieuserLoadedAction action) {
  return action.moxieuser;
}
