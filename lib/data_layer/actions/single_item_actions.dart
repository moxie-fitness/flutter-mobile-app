import 'package:meta/meta.dart';
import 'package:moxie_fitness/data_layer/actions/all_actions.dart';

class LoadSingleItem {
  final EModelTypes type;
  final itemId;
  LoadSingleItem({
    @required this.type,
    @required this.itemId
  });
}

class SingleItemLoaded {
  @required final EModelTypes type;
  @required final item;
  SingleItemLoaded({this.type, this.item});
}